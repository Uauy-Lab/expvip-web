require 'csv'
require 'optparse'

module Bio
	class Kallisto
		def self.getCommand(index:, fastq:, output_dir:,sd:0, single:false, bias:false, fragment_length:0, pseudobam:false, bootstrap_samples:0, threads:1, seed:42)

			extra = ""
			extra += " --single" if single
			extra += " --bias" if bias
			extra += " --sd=#{sd}" if sd > 0
			extra += " --fragment-length=#{fragment_length}" if fragment_length > 0
			extra += " --pseudobam" if pseudobam
			extra += " --bootstrap-samples=#{bootstrap-samples}" if bootstrap_samples > 0
			extra += " --threads=#{threads}" if threads > 1
			extra += " --seed=#{seed}" if seed != 42
			command = "kallisto quant --index=#{index} --output-dir=#{output_dir} #{extra} #{fastq.join(' ')}"
		end
	

		def self.getCommadPairedEnd(index:, output_dir:, left:, right:)
			l=left.split(":")
			r=right.split(":")
			raise "Reads should have at least one path for each pair" if l.size == 0 or r.size == 0
			raise "left and right reads must be paired." unless l.size == r.size
			reads=[]
			l.each_with_index do |e, i| 
				reads << e
				reads << r[i]
			end
			self.getCommand(index:index, fastq:reads, output_dir:output_dir)
		end

		def self.getCommadSingleEnd(index:, output_dir:, single:, fragment_length:, sd:0)
			s=single.split(":")
			raise "Reads should have at least one path" if s.size == 0
			reads=[]
			self.getCommand(index:index, single:true, fastq:s, output_dir:output_dir, fragment_length:fragment_length, sd:sd)
		end
	end

end

options = {}
options[:output_dir]="/nbi/group-data/ifs/NBI/Cristobal-Uauy/expression_browser/collaborators/kallisto/"
options[:index]="/nbi/Research-Groups/NBI/Cristobal-Uauy/TGACv1_annotation_CS42_ensembl_release/Triticum_aestivum_CS42_TGACv1_scaffold.annotation.gff3.cdna"
OptionParser.new do |opts|
	opts.banner = "Usage: prepare_kallisto_kommands_slurm.rb [options]"

	opts.on("-i", "--metadata FILE", "Metadata file. Must contain the columns Sample IDs,left,right,single,fragment_size,sd. By default the file is separated by tabs. Right, left and single can be array of files") do |v|
		options[:metadata] = v
	end

	opts.on("-o", "--output FILE", "File were the bash script for submission will be stored") do |v|
		options[:out] = v
	end

	opts.on("-f", "--output-dir FILE", "Folder where the samples will be mapped. There is going to be a folder for each study, and each study will contain subfolder") do |v|
		options[:output_dir] = v
	end

	opts.on("-r", "--index FILE", "Kallisto index") do |v|
		options[:index] = v
	end

	opts.on("-n","--ref_name NAME", "Name for the experiment. By default the filename of the index") do
		options[:ref_name] = v
	end
end.parse!
options[:ref_name] = options[:index].split("/")[-1] unless options[:ref_name] 

cmd_str=""
mkdir_str=""
i=0

CSV.foreach(options[:metadata], col_sep: "\t", headers:true) do |row|
	puts row
	i += 1
	l = row["left"]
	r = row["right"]
	study 	= row["study_title"].gsub(/\s+/,"_").gsub(",",".")
	id 	  	= row["Sample IDs"].gsub(/\s+/,"_").gsub(",",".")
	out_d ="#{options[:output_dir]}/#{options[:ref_name]}/#{study}/#{id}"
	mkdir_str += "\"#{out_d}\"\n" 
	if l and r
		cmd_str += "\"#{Bio::Kallisto.getCommadPairedEnd(index: options[:index], left:l, right:r,  output_dir:out_d)}" + "\"\n"  
	else
		single = row['single']
		fl = row['fragment_size'].to_i
		sd = row['sd'].to_f
		cmd_str += "\"#{Bio::Kallisto.getCommadSingleEnd(index: options[:index], single:single,fragment_length:fl, sd:sd, output_dir:out_d)}" + "\"\n"
	end
end

File.open(options[:out],"w") do |f|
	f.puts "#!/bin/bash"
	f.puts "#SBATCH --mem=25Gb"
	f.puts "#SBATCH -p tgac-medium "
	f.puts "#SBATCH -J kallisto_#{options[:ref_name]}"
	f.puts "#SBATCH -n 1"
	f.puts "#SBATCH -o log/kallisto_\%A_\%a.out"
	f.puts "#SBATCH --array=0-#{i}"
	f.puts "source kallisto-0.42.3"
	f.puts "i=$SLURM_ARRAY_TASK_ID"
	f.puts "declare -a out_dirs=(#{mkdir_str})"
	f.puts "declare -a commands=(#{cmd_str})"

	f.puts "cmd=${commands[$i]}"
	f.puts "out_dir=${out_dirs[$i]}"
	f.puts "echo $i"
	f.puts "echo $out_dir"
	f.puts "echo $cmd"
	f.puts "mkdir -p $out_dir"
	f.puts "srun $cmd"
end

