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
	task :study_names, [:filename]  => :environment do |t, args|
		puts "Updating studies"
		ActiveRecord::Base.transaction do
			CSV.foreach(args[:filename], :headers=>true, :col_sep=>",") do |row|
				study = Study.find_by(:accession=>row["secondary_study_accession"])
				study.title=row["study_title"]
				study.save!
			end
		end
	end

	desc "Update study properties. The columns should be: current_name	new_name	Grouping	summary	sra_description	manuscript	doi	order	selected	active"
	task :studies, [:filename] => :environment do |t,args|
		puts "Updating studies"
		ActiveRecord::Base.transaction do 
			CSV.foreach(args[:filename], headers: true, col_sep: ",") do |row|
				study = Study.find_by(:accession=>row["current_name"])
				raise "Study not found: #{row["current_name"]} (#{row.to_s})" if study.nil?  
				study.title           = row["new_name"]
				study.grouping        = row["Grouping"]
				study.doi             = row["doi"]
				study.order           = row["order"]
				study.manuscript      = row["manuscript"]
				study.summary         = row["summary"]
				study.sra_description = row["sra_description"]
				study.selected        = [1, true, '1', 'true'].include?(row["selected"]) 
				study.active          = [1, true, '1', 'true'].include?(row["active"]) 
				study.save!
			end
		end
	end

	desc "Move the gene to the description and infer the name from the gene"
	task :rename_gene_names,[:gene_set,:prefix] => :environment do |t, args|
		puts "Updating gene names for #{args[:gene_set]}"
		i = 0
		ActiveRecord::Base.transaction do
			gene_set = GeneSet.find_or_create_by(:name => args[:gene_set])
			Gene.find_by_sql("SELECT * FROM genes where gene not like '#{args[:prefix]}%' AND  gene_set_id='#{gene_set.id}'").each do |g|
				g.description = g.gene
				g.gene =  g.transcript.split(".")[0]
				i += 1
				g.save!
			end
		end
		puts "Modified #{i} transcripts"
	end

	desc "Migrate from mongo to mysql"
	task :mongo_to_mysql => :environment do |t, args|
		ExpressionValuesHelper.migrate_from_mongodb
	end
end
