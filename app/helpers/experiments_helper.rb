module ExperimentsHelper
	def self.saveExperiment(experiment)
		raise "Save using mongo is deprecated"
		@client = MongodbHelper.getConnection unless @client 
		experiment.save!
		doc = { :accession => experiment.accession } 
		@client[:experiments].update_one(
			{ :_id => experiment.id }, 
			{ '$set' => doc}, 
			upsert:true
			)

	end

	def self.saveValues(experiment, values)	
		raise "Save using mongo is deprecated"
		@client = MongodbHelper.getConnection unless @client 	
		@client[:experiments].find_one_and_update(
		 { :_id => experiment.id }, 
			{'$set' =>  values },
			:upsert => true 
			)
	end

end
