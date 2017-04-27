module GenesHelper

	def self.find(gene)
		@client = MongodbHelper.getConnection unless @client 
		gene_mongo = @client[:genes].find({:_id => gene.id}).first
		gene_mongo
	end
	def self.saveGene(gene)
		@client = MongodbHelper.getConnection unless @client 
		gene.save!
		doc = { :name => gene.name } 
		@client[:genes].update_one( 
			{ :_id => gene.id }, 
			{ '$set' => doc}, 
			upsert:true
			)
		
	end


	def self.saveValues(gene, type, values)		
		@client = MongodbHelper.getConnection unless @client 
		@client[:genes].update( { :_id => gene.id }, 
			'$set' => { type => values } )
	end
end
