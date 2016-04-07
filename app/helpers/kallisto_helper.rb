require 'set'
module KallistoHelper
	def self.runAndLoadFolder(input_dir:, kallistoIndex:, gene_set:, meta_experiment:)
		meta_exp = MetaExperiment.find_by(:name=>meta_experiment)
		used_accessions = Set.new
		experiments = Experiment.find_each do | e |
			next if(used_accessions.include?(e.accession))
			count = MetaExperimentsHelper.countLoadedValues(meta_experiment: meta_experiment, accession: e.accession )
			accession_dir = "#{input_dir}/#{e.accession}"
			files=Dir["#{accession_dir}/*.f*q*"]
			if(files.size != 0 and count == 0) 
				self.runAndLoad(input_dir:accession_dir, kallistoIndex: kallistoIndex, gene_set: gene_set, meta_experiment: meta_experiment )
			end
			used_accessions << e.accession
		end
	end
	
	def self.loadFolder(input_dir:, gene_set:, meta_experiment:)
		meta_exp = MetaExperiment.find_or_create_by(:name=>meta_experiment)
		used_accessions = Set.new
		experiments = Experiment.find_each do | e |
			next if(used_accessions.include?(e.accession))
			count = MetaExperimentsHelper.countLoadedValues(meta_experiment: meta_experiment, accession: e.accession )
			accession_dir = "#{input_dir}/#{e.accession}"
			
			files=Dir["#{accession_dir}/abundance.tsv"]
			if(count == 0 and files.size == 1 )  #Maybe improve this to make sure the actual kallisto files exist
				puts "Loading: #{e.accession} (#{gene_set})"
				self.loadKallistoOutput(input_dir:accession_dir, accession:e.accession, gene_set: gene_set, meta_experiment: meta_experiment )
			end
			used_accessions << e.accession
		end
	end


	def self.loadKallistoOutput(input_dir:, accession:, gene_set:, meta_experiment: )
		
		ActiveRecord::Base.transaction do
			conn = ActiveRecord::Base.connection
			experiment = Experiment.find_by(accession:accession)
			gene_set = GeneSet.find_by(:name=>gene_set)
			meta_exp = MetaExperiment.find_or_create_by(:name=>meta_experiment)
			count = MetaExperimentsHelper.countLoadedValues(meta_experiment: meta_experiment, accession:accession )

			Kernel::abort("accession #{accession} was not loaded with in the metadata!") unless experiment
			Kernel::abort("Gene set #{gene_set} was not loaded in the metadata!") unless gene_set
			Kernel::abort("Values for #{accession} are already loaded") unless count == 0

			tpm = TypeOfValue.find_or_create_by(:name=>"tpm")
			count_type = TypeOfValue.find_or_create_by(:name=>"count")

			puts "Loading gene names(#{gene_set.name})..."
			genes = Hash.new
			Gene.find_by_sql("SELECT * FROM genes where gene_set_id='#{gene_set.id}'").each do |g|  
				genes[g.name] = g.id
			end

			puts "Loaded #{genes.size} genes  in memory"
			puts "Loading values in db"
			count = 0
			inserts = Array.new

			json_stats = "#{input_dir}/run_info.json"
			abundance = "#{input_dir}/abundance.tsv"
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
					conn.execute sql
					inserts = Array.new
				end
			end
			sql = "INSERT INTO expression_values (`experiment_id`,`gene_id`, `meta_experiment_id`, `type_of_value_id`, `value`,`created_at`, `updated_at`) VALUES #{inserts.join(", ")}"
			conn.execute sql
			puts "Loaded #{count} ExpressionValue "
		end
	end

	def self.runAndLoad(input_dir:, kallistoIndex:, gene_set:, meta_experiment: )
		
		tmp_output="#{input_dir}/kallisto"
		files=Dir["#{input_dir}/*.f*q*"]
		accession=input_dir.split("/").last
		ActiveRecord::Base.transaction do
			conn = ActiveRecord::Base.connection
			#TODO: Add meta experiment to the load of genes, we should also be able to setup different references
			experiment = Experiment.find_by(accession:accession)
			gene_set = GeneSet.find_by(:name=>gene_set)
			meta_exp = MetaExperiment.find_or_create_by(:name=>meta_experiment)
			count = MetaExperimentsHelper.countLoadedValues(meta_experiment: meta_experiment, accession:accession )

			Kernel::abort("accession #{accession} was not loaded with in the metadata!") unless experiment
			Kernel::abort("Gene set #{gene_set} was not loaded in the metadata!") unless gene_set
			Kernel::abort("#{input_dir} doesn't have fastq files") if files.size == 0
			Kernel::abort("#{kallistoIndex} doesn't exist") unless File.exist?(kallistoIndex)
			Kernel::abort("Values for #{accession} are already loaded") unless count == 0

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