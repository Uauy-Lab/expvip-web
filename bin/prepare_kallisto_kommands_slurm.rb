require 'csv'
require 'optparse'

module Bio
	class Kallisto
		def self.getCommand(index:, fastq:, output_dir:,sd:0, single:false, bias:false, fragment_length:0, pseudobam:false, bootstrap_samples:100, threads:1, seed:42, keep_bam:false)

			extra = ""
			extra += " --single" if single
			extra += " --bias" if bias
			extra += " --sd=#{sd}" if sd > 0
			extra += " --fragment-length=#{fragment_length}" if fragment_length > 0
			extra += " --bootstrap-samples=#{bootstrap_samples}" if bootstrap_samples > 0
			extra += " --threads=#{threads}" if threads > 1
			extra += " --seed=#{seed}" if seed != 42
			command = "kallisto quant --index=#{index} --output-dir=#{output_dir} #{extra} #{fastq.join(' ')}"
		end


		def self.getCommadPairedEnd(index:, output_dir:, left:, right:, keep_bam:false)
			l=left.split(":")
			r=right.split(":")
			raise "Reads should have at least one path for each pair #{left}" if l.size == 0 or r.size == 0
			raise "left and right reads must be paired: \n#{left}\n#{right}" unless l.size == r.size
			reads=[]
			l.each_with_index do |e, i|
				reads << e
				reads << r[i]
			end
			#puts "PE: #{keep_bam}"
			self.getCommand(index:index, fastq:reads, output_dir:output_dir, keep_bam:keep_bam)
		end

		def self.getCommadSingleEnd(index:, output_dir:, single:, fragment_length:, sd:0, keep_bam:false)
			s=single.split(":")
			raise "Reads should have at least one path" if s.size == 0
			reads=[]
			self.getCommand(index:index, single:true, fastq:s, output_dir:output_dir, fragment_length:fragment_length, sd:sd, keep_bam:keep_bam)
		end
	end

end

options = {}
options[:output_dir] = "/nbi/group-data/ifs/NBI/Cristobal-Uauy/expression_browser/collaborators/kallisto/"
options[:index]		 = "/usr/users/ga002/ramirezr/Cristobal-Uauy/WGAv1.0/annotation/IWGSC_v1.1_ALL_20170706_transcripts.fasta.k31"
options[:keep_bam]	 = false

OptionParser.new do |opts|

	opts.banner = "Usage: prepare_kallisto_kommands_slurm.rb [options]"
	opts.on("-i", "--metadata FILE", "Metadata file. Must contain the columns Sample IDs,left,right,single,fragment_size,sd. By default the file is separated by tabs. Right, left and single can be array of files") do |v|
		options[:metadata] = v
	end
	opts.on("-o", "--output FILE", "Output bash script for submission will be stored") do |v|
		options[:out] = v
	end
	opts.on("-f", "--output-dir FILE", "Folder where the samples will be mapped. There is going to be a folder for each study, and each study will contain subfolder") do |v|
		options[:output_dir] = v
	end
	opts.on("-r", "--index FILE", "Kallisto index") do |v|
		options[:index] = v
	end
	opts.on("-n","--ref_name NAME", "Name for the experiment. By default the filename of the index") do |v|
		options[:ref_name] = v
	end

	opts.on("-k", "--keep_bam", " pseudo Keep BAM file") do
		options[:keep_bam] = true
	end

end.parse!

options[:ref_name] = options[:index].split("/")[-1] unless options[:ref_name]

cmd_str=""
mkdir_str=""
i=0

sam_str=""
CSV.foreach(options[:metadata], col_sep: "\t", headers:true) do |row|
	#puts row
	i += 1
	l = row["left"]
	r = row["right"]
	id = row["Sample.IDs"]
	id = row["Sample IDs"] unless id
	study 	= row["study_title"].gsub(/\s+/,"_").gsub(",",".").gsub(":",".")
	id 	  	= id.gsub(/\s+/,"_").gsub(",",".").gsub(":",".")
	out_d ="#{options[:output_dir]}/#{options[:ref_name]}/#{study}/#{id}"
	mkdir_str += "\"#{out_d}\"\n"
	output_prefix = "#{out_d}/#{id}"
	#output_sam = "#{out_d}/#{id}.sam"

	if l and r and l.length > 1 and r.length > 1
		cmd_str += "\"#{Bio::Kallisto.getCommadPairedEnd(index: options[:index], left:l, right:r,  output_dir:out_d, keep_bam: options[:keep_bam])}" + "\"\n"
	else
		single = row['single']
		fl = row['fragment_size'].to_i
		sd = row['sd'].to_f
		cmd_str += "\"#{Bio::Kallisto.getCommadSingleEnd(index: options[:index], single:single,fragment_length:fl, sd:sd, output_dir:out_d, keep_bam:options[:keep_bam])}" + "\"\n"
	end
	sam_str += "\"#{output_prefix}\"\n"
end

File.open(options[:out],"w") do |f|

	extra = ""
	extra =  get_bam_extra_string if options[:keep_bam]
	f.puts "#!/bin/bash"
	f.puts "#SBATCH --mem=25Gb"
	f.puts "#SBATCH -p jic-medium,nbi-medium,RG-Diane-Saunders"
	f.puts "#SBATCH -J kallisto_#{options[:ref_name]}"
	f.puts "#SBATCH -n 1"
	f.puts "#SBATCH -o log/kallisto_\%A_\%a.out"
	f.puts "#SBATCH --array=0-#{i}"
	f.puts "#SBATCH --time=12:00:00"
	f.puts "source kallisto-0.42.3"
	f.puts "source  samtools-1.4.1"
	f.puts "i=$SLURM_ARRAY_TASK_ID"
	f.puts "declare -a out_dirs=(#{mkdir_str})"
	f.puts "declare -a commands=(#{cmd_str})"
	f.puts "declare -a out_prefix=(#{sam_str})"

	f.puts "cmd=${commands[$i]}"
	f.puts "out_dir=${out_dirs[$i]}"
	f.puts "prefix=${out_prefix[$i]}"

	f.puts "echo $i"
	f.puts "echo $out_dir"
	f.puts "echo $cmd"

	f.puts "mkdir -p $out_dir"
	f.puts "if [ -s $out_dir/abundance.tsv ]\nthen\n\techo \"File $out_dir/abundance.tsv exists\""
	f.puts "else\n\tsrun $cmd #{extra} \nfi"
end
