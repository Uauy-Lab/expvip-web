module GenesHelper
	
	def self.get_random_genes(gene_set, count: 50)
		random_genes = Gene.where(gene_set_id: gene_set.id).order("RAND()").limit(count)
		example = {}
		example[:search]  = random_genes.first
		example[:compare] = random_genes.last
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
		#This only allows one gene for each.
		example[:search]  = Gene.where(id: example[:search] .first.gene_id).first
		example[:compare] = Gene.where(id: example[:compare].first.gene_id).first
		example[:heatmap] = example[:heatmap].map { |e| e.gene.gene  }
		example
	end
	
	def self.find(gene)
		raise "Mongo is deprecated"
		@client = MongodbHelper.getConnection unless @client 
		gene_mongo = @client[:genes].find({:_id => gene.id}).first
		gene_mongo
	end
	def self.saveGene(gene)
		raise "Mongo is deprecated"
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
			}
		).each do |t|
			transcripts << t
		end
		transcripts
	end
	
	
	def self.saveValues(gene, type, values)		
		@client = MongodbHelper.getConnection unless @client 
		@client[:genes].update({ 
			:_id => gene.id }, 
			'$set' => { type => values 
			}
		)
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

	def self.load_ensembl_genes(gene_set, filename)
		ActiveRecord::Base.transaction do
			gene_set = GeneSet.find_or_create_by(:name => gene_set)
			#puts gene_set.inspect
			Bio::FlatFile.open(Bio::FastaFormat, filename) do |ff|
			  ff.each do |entry|
				arr = entry.definition.split(/ description:"(.*?)" *| /)
				g = Gene.new
				g.gene_set = gene_set
				g.name = arr.shift
				arr.each { |e| g.add_field(e) }
				g.save!
				#GenesHelper.saveGene(g)
			  end
			end
		  end
	end

	def self.load_pangenome_cdna(gene_set, filename)
		ActiveRecord::Base.transaction do
			gene_set = GeneSet.find_or_create_by(:name => :gene_set)
			stream = Zlib::GzipReader.open(:filename) 
			i=0
			Bio::FlatFile.open(Bio::FastaFormat, stream) do |ff|
				ff.each do |entry|
					name = entry.entry_id
					arr = entry.entry_id.split(".")
					g = Gene.new
					g.gene_set = gene_set
					g.name = name
					g.transcript = name
					g.cdna = name
					g.gene = arr[0]
					g.save!
					i += 1
					puts "Loaded #{i} genes (#{g.transcript})" if i % 1000 == 0
				end
			end
		end
	end

	def load_de_novo_genes(gene_set, filename)
		puts "Loading genes"
		ActiveRecord::Base.transaction do
		gene_set = GeneSet.find_or_create_by(:name => :gene_set)

		Bio::FlatFile.open(Bio::FastaFormat, :filename) do |ff|
			ff.each do |entry|
				arr = entry.definition.split(/ description:"(.*?)" *| /)
				g = Gene.new
				g.gene_set = gene_set
				name = arr.shift
				g.name = name
				g.transcript = name
				g.cdna = name
				g.save!
				end
			end
		end
	end

	def load_gff_produced_gens(gene_sets, filename)
		puts "Loading gff produced genes"
		i = 0
		ActiveRecord::Base.transaction do
		gene_set = GeneSet.find_or_create_by(:name => args[:gene_set])
		puts gene_set.inspect
		Bio::FlatFile.open(Bio::FastaFormat, args[:filename]) do |ff|
			ff.each do |entry|
				arr = entry.definition.split(/\s|\t/)
				g = Gene.new
				g.gene_set = gene_set
				g.name = arr.shift
				fields = Hash.new
				arr.each do |e|
					f = e.split("=")
					fields[f[0]] = f[1]
				end
				g.transcript = g.name
				g.gene = fields["gene"]
				g.cdna = fields["biotype"]
				g.save!
				i += 1
				puts "Loaded #{i} genes (#{g.transcript})" if i % 1000 == 0
				end
			end
		end
		puts "Loaded #{i} genes"
	end
end
