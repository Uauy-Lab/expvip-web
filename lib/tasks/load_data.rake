require 'csv'  
require 'bio'
namespace :load_data do
  desc "Loads the metadata from the metadata file"
  task :metadata, [:filename]  => :environment do |t, args|
	  	puts "Loading metadata"

	  	ActiveRecord::Base.transaction do
		  	CSV.foreach(args[:filename], :headers => true, :col_sep => "\t") do |row|
		  		puts row.inspect
		  		species = Species.find_or_create_by(:scientific_name=>row["scientific_name"])
		  		
		  		#Maybe we need to validate that we are not overwritting. Look if there is a way to know if find_or_create tells which is the case. 
		  		study = Study.find_or_create_by(:accession=>row["secondary_study_accession"])
		  		study.title = 	row["study_title"]
		  		study.manuscript = row["Manuscript"]
		  		study.species = species
		  		study.save!
		  		variety = Variety.find_or_create_by(:name=>row["Variety"])
		  		tissue = Tissue.find_or_create_by(:name=>row["Tissue"])

		  		#We need to validate that it doesn't exist. Maybe make the accessions primary keys. 
		  		experiment = Experiment.new
		  		experiment.variety = variety
		  		experiment.tissue = tissue
		  		experiment.age = row["Age"]
		  		experiment.stress = row["Stress/disease"]
		  		experiment.accession = row["run_accession"]
		  		experiment.save!

		  		experiment_group = ExperimentGroup.find_or_create_by(:name=>row["Group_number_for_averaging"], :description=>row["Group_for_averaging"])
		  		experiment_group.experiments << experiment
		  		experiment_group.save!
		  	end
	  	end
  end

  desc "Load the genes, from the ENSEMBL fasta file."
  task :ensembl_genes, [:gene_set, :filename] => :environment do |t, args|
  	puts "Loading genes"
  	ActiveRecord::Base.transaction do
  		gene_set = GeneSet.find_or_create_by(:name=>args[:gene_set])

  		Bio::FlatFile.open(Bio::FastaFormat, args[:filename]) do |ff|
  			ff.each do |entry|
    			arr = entry.definition.split( / description:"(.*?)" *| / )
    			g = Gene.new 
    			g.gene_set = gene_set
    			g.name = arr.shift
				arr.each { |e| g.add_field(e) }
				g.save!
  			end
		end
  	end
  end

  def get_experiment(name)
  	@experiments[name] = Experiment.find_by(:accession=>name) unless @experiments[name]
  	return @experiments[name]
  end

  desc "Load the values from a csv file"
  task :values, [:meta_experiment, :gene_set, :value_type, :filename ] => :environment do |t, args| 
  	ActiveRecord::Base::transaction do
  		meta_exp = MetaExperiment.find_or_create_by(:name=>args[:meta_experiment])
  		gene_set = GeneSet.find_by(:name=>args[:gene_set])
  		value_type = TypeOfValue.find_or_create_by(:name=>args[:value_type])
  		@experiments = Hash.new

  		#genes_arr = Gene.connection.select_all("SELECT * FROM clients WHERE id = '1'")
  		genes = Hash.new

  		Gene.find_by_sql("SELECT * FROM genes where gene_set_id='#{gene_set.id}'").each do |g|  
  			genes[g.name] = g

  		end
  		puts "Loaded #{genes.size} genes  in memory"
  		CSV.foreach(args[:filename], :headers => true, :col_sep => "\t") do |row|
  			#puts row.inspect

  			#gene = Gene.find_by(:name=>row["target_id"])
  			gene = genes[row["target_id"]]
  			puts gene
  			row.delete("target_id")
  			row.to_hash.each_pair do |name, val| 
  				val = val.to_f
  				next if val == 0
  				ev = ExpressionValue.new
  				ev.gene = gene
  				ev.meta_experiment = meta_exp
  				ev.type_of_value = value_type
  				ev.experiment = get_experiment(name)
  				ev.value = val
  				ev.save!
  				#puts ev.inspect
  			end
  			
  		end
  	end
  end

end
