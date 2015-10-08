namespace :updatenames do
	desc "Updates the short and long names of the factors. The input is a CSV file"
	task :factors, [:filename]  => :environment do |t, args|
		puts "Updating factors"
		ActiveRecord::Base.transaction do
			CSV.foreach(args[:filename], :headers =>true, :col_sep=>",") do |row|
				factor = Factor.find(row["id"].to_i)
				factor.name = row["Short"]
				factor.description = row["Long"]
				factor.save!
			end
		end
	end

	desc "Update the study names. "
	task :studies, [:filename]  => :environment do |t, args|
		puts "Updating studies"
		ActiveRecord::Base.transaction do
			CSV.foreach(args[:filename], :headers=>true, :col_sep=>",") do |row|
				#puts row.inspect
				study = Study.find_by(:accession=>row["secondary_study_accession"])
				#puts study.inspect
				study.title=row["study_title"]
				study.save!
			end
		end
	end
end
