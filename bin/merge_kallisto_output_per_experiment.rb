require 'csv'
require 'fileutils'
require 'optparse'
require 'json'

options = {}
options[:output_dir]="/nbi/group-data/ifs/NBI/Cristobal-Uauy/expression_browser/collaborators/kallisto/"
options[:index]="/usr/users/ga002/ramirezr/Cristobal-Uauy/WGAv1.0/annotation/IWGSCv1.0_UTR_ALL.cdnas.fasta.gz.k31"
options[:study_title] = nil
options[:out] = options[:output_dir]
OptionParser.new do |opts|
	opts.banner = "Usage: prepare_kallisto_kommands_slurm.rb [options]"

	opts.on("-i", "--metadata FILE", "Metadata file. Must contain the columns Sample IDs,left,right,single,fragment_size,sd. By default the file is separated by tabs. Right, left and single can be array of files") do |v|
		options[:metadata] = v
	end

	opts.on("-o", "--kallisto-output DIR", "Folder were the matrices will be stored") do |v|
		options[:output_dir] = v
	end

	opts.on("-f", "--output-dir DIR", "Folder where the samples were mapped. The folder should contain a subfolder for each study, and each study contains a folder with the kallisto output of each sample") do |v|
		options[:out] = v
		puts v
	end

	opts.on("-r", "--index FILE", "Kallisto index") do |v|
		options[:index] = v
	end

	opts.on("-n","--ref_name NAME", "Name for the experiment. By default the filename of the index") do |v|
		options[:ref_name] = v
	end

	opts.on("-s","--study_title NAME", "Study to extract") do |v|
		options[:study_title] = v
	end

end.parse!
options[:ref_name] = options[:index].split("/")[-1] unless options[:ref_name] 


cmd_str=""
mkdir_str=""
i=0
k=0
all_samples_tpm   = Array.new
all_samples_count = Array.new

all_samples_tpm_by_gene   = Hash.new {|h,k| h[k] = Hash.new {|h2,k2| h2[k2] = 0 } }
all_samples_count_by_gene = Hash.new {|h,k| h[k] = Hash.new {|h2,k2| h2[k2] = 0 } }


all_samples_count_sum = Array.new


headers = Array.new
headers << "transcript"


CSV.foreach(options[:metadata], col_sep: "\t", headers:true) do |row|
	study 	= row["study_title"].gsub(/\s+/,"_").gsub(",",".").gsub(":",".")
	id 	  	= row["Sample IDs"].gsub(/\s+/,"_").gsub(",",".").gsub(":",".")

	out_d ="#{options[:output_dir]}/#{options[:ref_name]}/#{study}/#{id}"
	k+=1
	#$stderr.puts "Comparing: '#{row["study_title"]}' '#{options[:study_title]}'"
	if options[:study_title] 
		next unless row["study_title"] == options[:study_title] 
	end
	$stderr.puts "Reading #{id}"
	abundace_f="#{out_d}/abundance.tsv"
	unless File.exist? abundace_f
		$stderr.puts "Missing aboundace.tsv for: #{id}"
		$stderr.puts abundace_f
		next
	end

	abundace_json="#{out_d}/run_info.json"
	run_info_file = File.read(abundace_json)
	run_info = JSON.parse(run_info_file)
	total_reads = run_info["n_processed"]

	i += 1
	j = 0
	headers << id 
	
	CSV.foreach(abundace_f, col_sep: "\t", headers:true) do |row2|
		if i == 1
			all_samples_tpm[j]  = []
			all_samples_count[j] = []
			all_samples_tpm[j]   << row2["target_id"] 
			all_samples_count[j] << row2["target_id"] 
		end

		gene = row2["target_id"].split(".")[0]

		all_samples_tpm[j]   << row2["tpm"]
		all_samples_count[j] << row2["est_counts"]

		all_samples_tpm_by_gene[gene][i] += row2["tpm"].to_f
		all_samples_count_by_gene[gene][i] += row2["est_counts"].to_f
		j += 1
	end
	all_samples_count_sum <<  [id, 
		total_est.round, 
		total_reads, 
		 (100*total_est/total_reads).round(2) ]
end
study 	= options[:study_title].gsub(/\s+/,"_").gsub(",",".").gsub(":",".")


FileUtils.mkdir_p options[:out] + "/ByTranscript"
FileUtils.mkdir_p options[:out] + "/ByGene"


File.open(options[:out] + "/#{options[:study_title]}_summary.tsv", "w") do |file|  
	file.puts headers.join "\t"
	all_samples_count_sum.each { |e|  file.puts e.join "\t" }
end

	
File.open(options[:out] + "/ByTranscript/#{study}_tpm.tsv", "w") do |file|  
	file.puts headers.join "\t"
	all_samples_tpm.each { |e|  file.puts e.join "\t" }
end


File.open(options[:out] + "/ByTranscript/#{study}_count.tsv", "w") do |file|  
	file.puts headers.join "\t"
	all_samples_count.each { |e|  file.puts e.join "\t" }
end

headers[0] = "gene"
File.open(options[:out] + "/ByGene/#{study}_tpm.tsv", "w") do |file|  
	file.puts headers.join "\t"
	all_samples_tpm_by_gene.each_pair do |gene, values|  
		tmp = []
		tmp << gene
		values.keys.sort.each{|e| tmp << values[e]}
		file.puts tmp.join "\t"
	end
end


File.open(options[:out] + "/ByGene/#{study}_count.tsv", "w") do |file|  
	file.puts headers.join "\t"
	all_samples_count_by_gene.each_pair do |gene, values|  
		tmp = []
		tmp << gene
		values.keys.sort.each{|e| tmp << values[e]}
		file.puts tmp.join "\t"
	end
end

