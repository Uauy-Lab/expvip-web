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
    			puts entry.definition
    			#arr = entry.definition.split()
    			
    			arr = entry.definition.split( / description:"(.*?)" *| / )
    			puts arr.inspect
    			
    			g = Gene.new 
    			g.gene_set = gene_set
    			g.name = arr.shift
    			#puts g.inspect
#    			puts arr.inspect
				arr.each { |e| g.add_field(e) }
				#puts g.inspect
				g.save!
  			end
		end
  	end
  end

  desc "TODO"
  task fpkm: :environment do
  end

end
