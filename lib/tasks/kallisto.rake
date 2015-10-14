require 'csv'  
require 'bio'
require 'bio-kallisto'
require 'json'
namespace :kallisto do
	desc "Runs kallisto and stores the results in the database. The experiment should be already loaded in the database"
	task :runAndStorePaired, [:kallistoIndex, :input_dir, :meta_experiment, :gene_set ]  => :environment do |t, args|

		input_dir = args[:input_dir]
		kallistoIndex = args[:kallistoIndex]
		tmp_output="#{input_dir}/kallisto"
		files=Dir["#{input_dir}/*.f*q*"]
		accession=input_dir.split("/").last
		ActiveRecord::Base.transaction do
			conn = ActiveRecord::Base.connection
			#TODO: Add meta experiment to the load of genes, we should also be able to setup different references
			experiment = Experiment.find_by(accession:accession)
			gene_set = GeneSet.find_by(:name=>args[:gene_set])
			meta_exp = MetaExperiment.find_or_create_by(:name=>args[:meta_experiment])
			Kernel::abort("accession #{accession} was not loaded with in the metadata!") unless experiment
			Kernel::abort("Gene set #{args[:gene_set]} was not loaded in the metadata!") unless gene_set
			Kernel::abort("#{input_dir} doesn't have fastq files") if files.size == 0
			Kernel::abort("#{kallistoIndex} doesn't exist") unless File.exist?(kallistoIndex)

			tpm = TypeOfValue.find_or_create_by(:name=>"tpm")
			count_type = TypeOfValue.find_or_create_by(:name=>"count")

			puts "Running Kallisto..."
			Bio::Kallisto.map(index:kallistoIndex, fastq:files, output_dir:tmp_output)
			puts "Loading gene names(#{gene_set.name})..."
			genes = Hash.new
			Gene.find_by_sql("SELECT * FROM genes where gene_set_id='#{gene_set.id}'").each do |g|  
				genes[g.name] = g.id
			end

			puts "Loaded #{genes.size} genes  in memory"
			puts "Loading values in db"
			count = 0
			inserts = Array.new

			json_stats = "#{tmp_output}/run_info.json"
			abundance = "#{tmp_output}/abundance.tsv"
			file = File.read(json_stats)
			data_hash = JSON.parse(file)

			CSV.foreach(abundance, :headers=>true, :col_sep=>"\t") do |row|
				gene = genes[row["target_id"]]
				val= row["est_counts"]
				str = "(#{experiment.id},#{gene},#{meta_exp.id},#{count_type.id},#{val},NOW(),NOW())"
				inserts.push str   
				val= row["tpm"]
				str = "(#{experiment.id},#{gene},#{meta_exp.id},#{tpm.id},#{val},NOW(),NOW())"
				inserts.push str   
				count += 1   
				if count % 1000 == 0
					puts "Loaded #{count} ExpressionValues (#{row["target_id"]})" 
					sql = "INSERT INTO expression_values (`experiment_id`,`gene_id`, `meta_experiment_id`, `type_of_value_id`, `value`,`created_at`, `updated_at`) VALUES #{inserts.join(", ")}"
          			#puts sql
          			conn.execute sql
          			inserts = Array.new
          		end
          	end
          	puts "Loaded #{count} ExpressionValue " 
          	sql = "INSERT INTO expression_values (`experiment_id`,`gene_id`, `meta_experiment_id`, `type_of_value_id`, `value`,`created_at`, `updated_at`) VALUES #{inserts.join(", ")}"
      		#puts sql
      		conn.execute sql
		end
	end
end

