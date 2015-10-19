require 'csv'  
require 'bio'
require 'bio-kallisto'
require 'json'
namespace :kallisto do
	desc "Runs Kallisto and stores the results in the database. The experiment should be already loaded in the database"
	task :runAndStorePaired, [:kallistoIndex, :input_dir, :meta_experiment, :gene_set ]  => :environment do |t, args|
		KallistoHelper.runAndLoad(
			input_dir:args[:input_dir], 
			kallistoIndex:args[:kallistoIndex],
			gene_set: args[:gene_set], 
			meta_experiment: args[:meta_experiment]
			)
	end

	desc "Runs Kallisto in all the folders in the directory that have an entry in the database. If the analysis has been loaded, Kallisto is not run again."
	task :runAndStorePairedFolder, [:kallistoIndex, :input_dir, :meta_experiment, :gene_set ]  => :environment do |t, args|
		KallistoHelper.runAndLoadFolder(
			input_dir:args[:input_dir], 
			kallistoIndex:args[:kallistoIndex],
			gene_set: args[:gene_set], 
			meta_experiment: args[:meta_experiment]
			)
	end


end

