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

	def self.getExperimentGroups 
		experiments = Hash.new
		groups = Hash.new
		Experiment.find_each do |g|
			group = Hash.new
			next unless g.study.active
			#Should we use description instead?
			group["name"] = g.accession
			group["description"] = g.accession
			factors = Hash.new
			g.factors.each { |f| factors[f.factor] = f.name } #TODO: This may be cached

			experiments[g.id] = Hash.new
			exp = experiments[g.id]
			exp["name"] = g.accession
			exp["group"] = g.id.to_s
			factors["study"] = g.study.accession

			group["factors"] = factors
			groups[g.id] = group
			end
		return [experiments, groups]
	end

end
