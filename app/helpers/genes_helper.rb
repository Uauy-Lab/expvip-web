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

	def self.findTranscripts(gene_name)
		transcripts = Array.new
		Gene.where("gene = :gene_name", {gene_name: gene_name}).each do |t|
		 transcripts<<t
		end
		transcripts
	end


	def self.saveValues(gene, type, values)		
		@client = MongodbHelper.getConnection unless @client 
		@client[:genes].update({ 
			:_id => gene.id }, 
			'$set' => { type => values 
		})
	end

	def self.load_gene_hash(gene_set)
	  genes = Hash.new
      Gene.find_by_sql("SELECT * FROM genes where gene_set_id='#{gene_set.id}'").each do |g|  
        genes[g.name] = g
      end
      genes
	end
end
