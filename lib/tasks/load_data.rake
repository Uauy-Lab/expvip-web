require 'csv'  
namespace :load_data do
  desc "Loads the metadata from the metadata file"
  task :metadata, [:filename]  => :environment do |t, args|
  		puts "Args were: #{args}"
  		puts Rails.env
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

		  		variety = Variety.find_or_create_by(:name=>row["Variety"])
		  		tissue = Tissue.find_or_create_by(:name=>row["Tissue"])


		  		#We need to validate that it doesn't exist. Maybe make the accessions primary keys. 
		  		experiment = Experiment.new
		  		experiment.variety = variety
		  		experiment.tissue = tissue
		  		experiment.age = row["Age"]
		  		experiment.stress = row["Stress/disease"]
		  		experiment.accession = row["run_accession"]

		  		experiment_group = ExperimentGroup.find_or_create_by(:name=>row["Group_number_for_averaging"], :description=>row["Group_for_averaging"])
		  		experiment_group.experiments << experiment
		  		

		  	end
	  	end
  end

  desc "TODO"
  task fpkm: :environment do
  end

end
