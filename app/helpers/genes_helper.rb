module GenesHelper

	def self.get_random_genes(gene_set, count: 50)
		random_genes = Gene.where(gene_set_id: gene_set.id).order("RAND()").limit(count)
		example = {}
		example[:search]  = random_genes.first(3)
		example[:compare] = random_genes.last(2)
		example[:heatmap] = random_genes.map { |e| e.gene }
		example
	end

	def self.get_example_genes(gene_set)
		example = {}
		example[:search]  = SampleGene.where(gene_set_id: gene_set.id, kind:'search')
		example[:compare] = SampleGene.where(gene_set_id: gene_set.id, kind:'compare')
		example[:heatmap] = SampleGene.where(gene_set_id: gene_set.id, kind:'heatmap')
		if example[:search].size == 0
			return get_random_genes(gene_set)  
		end
		example[:search_1]  = Gene.where(id: example[:search][0].gene_id).first
		example[:search_2]  = Gene.where(id: example[:search][1].gene_id).first
		example[:search_3]  = Gene.where(id: example[:search][2].gene_id).first
		example[:compare_1] = Gene.where(id: example[:compare][0].gene_id).first
		example[:compare_2] = Gene.where(id: example[:compare][1].gene_id).first
		example[:heatmap] = example[:heatmap].map { |e| e.gene.gene  }
		example
	end

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

	def self.findTranscripts(gene_name, gene_set)
		transcripts = Array.new
		Gene.where("gene = :gene_name AND gene_set_id = :gene_set", 
			{
				gene_name: gene_name, 
				gene_set: gene_set.id
			}).each do |t|
			transcripts << t
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

	def self.findGeneName(gene_name, gene_set)
    gene = Gene.find_by(:name=>gene_name, :gene_set_id=>gene_set.id)      
    gene = Gene.find_by(:gene=>gene_name, :gene_set_id=>gene_set.id) unless  gene     
    raise "\n\n\nGene not found: #{gene_name} for #{gene_set.name}\n\n\n" unless gene
    return [gene,  gene_name == gene.gene ? "gene": "transcript" ]  
  end
end
