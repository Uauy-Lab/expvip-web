require 'csv'
require 'optparse'

module Bio
	class Hisat2

		def self.getCommadPairedEnd(left, right, unpaired, index, output_sam, sample, threads:1)
			l=left
			r=right
			u=unpaired
			raise "Reads should have at least one path for each pair" if l.size == 0 or r.size == 0
			raise "left and right reads must be paired: \n#{left}\n#{right}" unless l.size == r.size
			extra  = " --threads #{threads}"
			extra += " --time --downstream-transcriptome-assembly --mm"
			extra += " --rg-id #{sample}"
			extra += " --rg SM:#{sample}"
			extra += " --rg LB:#{sample}"
			cmd = "hisat2  #{extra} -x #{index} -1 #{l.join(",")} -2 #{r.join(",")} -U #{u.join(",")}  -S #{output_sam}"
		end
	end
end

options = {}
options[:output_dir]="/nbi/scratch/ramirezr/expression_browser/collaborators/hisat/"
options[:index]="/nbi/group-data/ifs/NBI/Cristobal-Uauy/WGAv1.0/161010_Chinese_Spring_v1.0_pseudomolecules"
options[:threads] = 1

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

	opts.on("-t", "--threads INT", "Number of threads") do |v|
		options[:threads] = v.to_i
	end
end.parse!

cmd_str=""
mkdir_str=""
sam_str=""
i=0

CSV.foreach(options[:metadata], col_sep: "\t", headers:true) do |row|
	#puts row
	
	l = row["left"]
	r = row["right"]
	single = row['single']
	study 	= row["study_title"].gsub(/\s+/,"_").gsub(",",".").gsub(":",".")
	id 	  	= row["Sample IDs"].gsub(/\s+/,"_").gsub(",",".").gsub(":",".")
	out_d ="#{options[:output_dir]}/#{study}/#{id}"

	mkdir_str += "\"#{out_d}\"\n" 
	if l and r
		#cmd_str += "\"#{Bio::Kallisto.getCommadPairedEnd(index: options[:index], left:l, right:r,  output_dir:out_d)}" + "\"\n" 
		l=l.split(":")
		r=r.split(":")
		u=single.split(":")
		raise "Reads should have at least one path for each pair" if l.size == 0 or r.size == 0
		raise "left and right reads must be paired: \n#{l}\n#{r}" unless l.size == r.size
		output_prefix = "#{out_d}/#{id}"
		output_sam = "#{out_d}/#{id}.sam"
		cmd_str += "\"#{Bio::Hisat2.getCommadPairedEnd(l, r, u, options[:index],  output_sam, id, threads:1)}" + "\"\n"  
		sam_str += "\"#{output_sam}\"\n" 
		i += 1
	else
		throw "Unsupported single end reads"
	end
end


File.open("#{options[:out]}.sh","w") do |f|
	f.puts "#!/bin/bash"
	f.puts "#SBATCH --mem=25Gb"
	f.puts "#SBATCH -p nbi-medium,RG-Cristobal-Uauy"
	f.puts "#SBATCH -J hisat_#{options[:ref_name]}"
	f.puts "#SBATCH -n 1"
	f.puts "#SBATCH --cpus-per-task=#{options[:threads]}"
	f.puts "#SBATCH -o log/hisat2_\%A_\%a.out"
	f.puts "#SBATCH --array=0-#{i}"
	f.puts "source  samtools-1.4.1"
	f.puts "source /tgac/software/testing/bin/HISAT-2.0.5"
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
	 
	f.puts "srun $cmd \n"
	f.puts "srun samtools view -bS $prefix > $prefix.bam "
	f.puts "srun rm $prefix.sam "
	f.puts "srun samtools sort -m 5G -@#{options[:threads]} -o $prefix.sorted.bam $prefix.bam "

end

