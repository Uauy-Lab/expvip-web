module ExperimentsHelper
	def self.saveExperiment(experiment)
		@client = MongodbHelper.getConnection unless @client 
		experiment.save!
		doc = { :accession => experiment.accession } 
		@client[:experiments].update_one(
			{ :_id => experiment.id }, 
			{ '$set' => doc}, 
			upsert:true
			)

	end

	def self.saveValues(experiment, type, values)	
		@client = MongodbHelper.getConnection unless @client 	
		@client[:experiments].update( { :_id => experiment.id }, 
			'$set' => { type => values } )
	end

end
