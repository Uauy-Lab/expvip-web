require 'csv'
require 'optparse'

options = {}
options[:output_dir]="/nbi/group-data/ifs/NBI/Cristobal-Uauy/expression_browser/collaborators/kallisto/"
options[:index]="/nbi/Research-Groups/NBI/Cristobal-Uauy/TGACv1_annotation_CS42_ensembl_release/Triticum_aestivum_CS42_TGACv1_scaffold.annotation.gff3.cdna"
OptionParser.new do |opts|
	opts.banner = "Usage: prepare_kallisto_kommands_slurm.rb [options]"

	opts.on("-i", "--metadata FILE", "Metadata file. Must contain the columns Sample IDs,left,right,single,fragment_size,sd. By default the file is separated by tabs. Right, left and single can be array of files") do |v|
		options[:metadata] = v
	end

	opts.on("-o", "--output FILE", "File prefix where the table will be stored") do |v|
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

all_samples_tpm   = Array.new
all_samples_count = Array.new
headers = Array.new
headers << "Sample"
tpm_f = File.open(options[:out] + "_tpm.tsv", "w")
count_f = File.open(options[:out] + "_count.tsv", "w")
CSV.foreach(options[:metadata], col_sep: "\t", headers:true) do |row|
	#puts row
	study 	= row["study_title"].gsub(/\s+/,"_").gsub(",",".").gsub(":",".")
	id 	  	= row["Sample IDs"].gsub(/\s+/,"_").gsub(",",".").gsub(":",".")
	out_d ="#{options[:output_dir]}/#{options[:ref_name]}/#{study}/#{id}"

	

	abundace_f="#{out_d}/abundance.tsv"
	unless File.exist? abundace_f
		$stderr.puts "Missing aboundace.tsv for: #{id}"
		next
	end
	i += 1
	j = 0
	all_samples_tpm  [j] = id 
	all_samples_count[j] = id 
	CSV.foreach(abundace_f, col_sep: "\t", headers:true) do |row2|
		j += 1
		headers[j] = row2["target_id"] if i == 1 
		all_samples_tpm  [j] = row2["tpm"]
		all_samples_count[j] = row2["est_counts"]		
	end
	tpm_f.puts headers.join("\t") if i == 1
	count_f.puts headers.join("\t") if i == 1

	tpm_f.puts all_samples_tpm.join("\t") 
	count_f.puts all_samples_count.join("\t") 
end
count_f.close
tpm_f.close
