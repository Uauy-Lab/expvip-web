module GenesHelper
	def self.saveGene(gene)
		@client = MongodbHelper.getConnection unless @client 
		gene.save!
		gene_mongo = @client[:genes].find({:_id => gene.id}).first
		doc = { :_id => gene.id, :name => gene.name } 
		@client[:genes].insert_one doc 	unless gene_mongo
	end
end
