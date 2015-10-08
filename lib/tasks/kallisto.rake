require 'csv'  
require 'bio'
require 'bio-kallisto'

namespace :kallisto do
  desc "Runs kallisto and stores the results in the database. The experiment should be already loaded in the database"
  task :runAndStore, [:filename, :kallistoIndex]  => :environment do |t, args|


	#Bio::Kallisto.map(index:ARGV[0], fastq:[ARGV[1], ARGV[2]], output_dir:ARGV[3] ) 	
  end
end
