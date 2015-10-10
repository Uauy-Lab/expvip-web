require 'csv'  
require 'bio'
require 'bio-kallisto'
 require 'json'
namespace :kallisto do
  desc "Runs kallisto and stores the results in the database. The experiment should be already loaded in the database"
  task :runAndStorePaired, [:kallistoIndex, :input_dir, :meta_experiment ]  => :environment do |t, args|

  	input_dir = args[:input_dir]
  	kallistoIndex = args[:kallistoIndex]
  	tmp_output="#{input_dir}/kallisto"
	files=Dir["#{input_dir}/*.f*q*"]
	accession=input_dir.split("/").last

	#TODO: Add meta experiment to the load of genes, we should also be able to setup different references
	experiment = Experiment.find_by(accession:accession)
	meta_exp = MetaExperiment.find_or_create_by(:name=>args[:meta_experiment])
	Kernel::abort("accession #{accession} was not loaded with the metadata!") unless experiment
	Kernel::abort("#{input_dir} doesn't have fastq files") if files.size == 0
	Kernel::abort("#{kallistoIndex} doesn't exist") unless File.exist?(kallistoIndex)

	tpm = TypeOfValue.find_or_create_by(:name=>"tpm")

	count = TypeOfValue.find_or_create_by(:name=>"count")


	puts "Running Kallisto..."
#	Bio::Kallisto.map(index:kallistoIndex, fastq:files, output_dir:tmp_output)
	puts "Loading values in db"
	ActiveRecord::Base.transaction do
		json_stats = "#{tmp_output}/run_info.json"
		abundance = "#{tmp_output}/abundance.tsv"
		file = File.read(json_stats)
		data_hash = JSON.parse(file)

		CSV.foreach(abundance, :headers=>true, :col_sep=>"\t") do |row|
			#puts row.inspect
			g = Gene.find_by(name: row["target_id"])
			
			ev = ExpressionValue.new
			ev.gene = g
			ev.meta_experiment = meta_exp
			ev.experiment = experiment
			ev.type_of_value = tpm
			ev.value = row["tpm"]

			ev2 = ExpressionValue.new
			ev2.gene = g
			ev2.meta_experiment = meta_exp
			ev2.experiment = experiment
			ev2.type_of_value = count
			ev2.value = row["est_counts"]


			ev.save!
			ev2.save!
		end
	end

  	
  end
end
