module ExperimentsHelper
	def self.saveExperiment(experiment)
		@client = MongodbHelper.getConnection unless @client 
		experiment.save!
		exp_mongo = @client[:experiments].find({:_id => experiment.id}).first
		doc = { :_id => experiment.id, :accession => experiment.accession } 
		@client[:experiments].insert_one doc unless exp_mongo	
	end
end
