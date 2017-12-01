require 'csv'
require 'optparse'

module Bio
	class Trimmomatic

		def self.getCommadPairedEnd(inputFile1, inputFile2, outputFile1P, outputFile1U, outputFile2P, outputFile2U)
			cmd =   "java -jar /nbi/software/testing/bin/core/../..//trimmomatic/0.33/x86_64/bin/trimmomatic-0.33.jar PE -threads 4 -phred33  " 
			cmd << "#{inputFile1} #{inputFile2} #{outputFile1P} #{outputFile1U} #{outputFile2P} #{outputFile2U} "			
			cmd << "ILLUMINACLIP:TruSeq3-PE.fa:2:30:10 LEADING:5 TRAILING:5 MINLEN:36" 
			cmd
		end
	end
end

options = {}
options[:output_dir]="/nbi/scratch/ramirezr/expression_browser/collaborators/trimmomatic/"

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
end.parse!

cmd_str=""
mkdir_str=""
i=0
out = File.open("#{options[:out]}.tab","w")
CSV.foreach(options[:metadata], col_sep: "\t", headers:true) do |row|
	#puts row
	
	l = row["left"]
	r = row["right"]
	study 	= row["study_title"].gsub(/\s+/,"_").gsub(",",".").gsub(":",".")
	id 	  	= row["Sample IDs"].gsub(/\s+/,"_").gsub(",",".").gsub(":",".")
	out_d ="#{options[:output_dir]}/#{study}/#{id}"
	mkdir_str += "\"#{out_d}\"\n" 
	if l and r
		#cmd_str += "\"#{Bio::Kallisto.getCommadPairedEnd(index: options[:index], left:l, right:r,  output_dir:out_d)}" + "\"\n" 
		l=l.split(":")
		r=r.split(":")
		raise "Reads should have at least one path for each pair" if l.size == 0 or r.size == 0
		raise "left and right reads must be paired: \n#{left}\n#{right}" unless l.size == r.size
		new_l = Array.new
		new_r = Array.new
		new_s = Array.new
		

		l.each_with_index do |l1, j|  
			r1=r[j]
			base = File.basename l1
			new_file_lp = "#{out_d}/LP#{j}_#{base.split(".")[0]}.fastq.gz"
			new_file_lu = "#{out_d}/LU#{j}_#{base.split(".")[0]}.fastq.gz"
			base = File.basename r1
			new_file_rp = "#{out_d}/RP#{j}_#{base.split(".")[0]}.fastq.gz"
			new_file_ru = "#{out_d}/RU#{j}_#{base.split(".")[0]}.fastq.gz"

			new_l << new_file_lp
			new_r << new_file_rp
			new_s << new_file_lu
			new_s << new_file_ru
			i += 1
			cmd = Bio::Trimmomatic.getCommadPairedEnd(l1,r1, new_file_lp, new_file_lu, new_file_rp, new_file_ru)
			cmd_str += "\"#{cmd}\"\n"
		end

		row["left"]   = new_l.join(":")
		row["right"]  = new_r.join(":")
		row["single"] = new_s.join(":")
		out.puts row.fields.join("\t")
	else
		throw "Unsupported single end reads"
		single = row['single']
		fl = row['fragment_size'].to_i
		sd = row['sd'].to_f
		cmd_str += "\"#{Bio::Kallisto.getCommadSingleEnd(index: options[:index], single:single,fragment_length:fl, sd:sd, output_dir:out_d)}" + "\"\n"
	end
end

out.close

File.open("#{options[:out]}.sh","w") do |f|
	f.puts "#!/bin/bash"
	f.puts "#SBATCH --mem=25Gb"
	f.puts "#SBATCH -p nbi-medium,RG-Cristobal-Uauy"
	f.puts "#SBATCH -J kallisto_#{options[:ref_name]}"
	f.puts "#SBATCH -n 1"
	f.puts "#SBATCH --cpus-per-task=4"
	f.puts "#SBATCH -o log/trimmomatic_\%A_\%a.out"
	f.puts "#SBATCH --array=0-#{i}"
	f.puts "source  trimmomatic-0.33"
	f.puts "i=$SLURM_ARRAY_TASK_ID"
	f.puts "declare -a out_dirs=(#{mkdir_str})"
	f.puts "declare -a commands=(#{cmd_str})"

	f.puts "cmd=${commands[$i]}"
	f.puts "out_dir=${out_dirs[$i]}"
	f.puts "echo $i"
	f.puts "echo $out_dir"
	f.puts "echo $cmd"

	f.puts "mkdir -p $out_dir"
	 
	f.puts "srun $cmd \n"
end

