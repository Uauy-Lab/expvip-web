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

		Rails.cache.fetch("getExperimentGroups", expires_in: 24.hours) do
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
			[experiments, groups]
		end
		
	end

	def self.getFactorOrder
		factorOrder = Hash.new
		longFactorName = Hash.new
		selectedFactors = Hash.new

		Study.find_each do |s|
			next unless s.active
			factorOrder["study"] = Hash.new unless factorOrder["study"]
			longFactorName["study"] = Hash.new unless longFactorName["study"]
			selectedFactors["study"] = Hash.new unless selectedFactors["study"]
			order = factorOrder["study"]
			longName = longFactorName["study"]
			selected = selectedFactors["study"]

			order[s.accession] = s.order
			longName[s.accession] = s.title
			longName[s.accession] = s.accession unless s.title
			selected[s.accession] = true
		end

		Factor.find_each do |f|
			factorOrder[f.factor] = Hash.new unless factorOrder[f.factor]
			longFactorName[f.factor] = Hash.new unless longFactorName[f.factor]
			selectedFactors[f.factor] = Hash.new unless selectedFactors[f.factor]

			order = factorOrder[f.factor]
			longName = longFactorName[f.factor]
			selected = selectedFactors[f.factor]

			order[f.name] = f.order
			longName[f.name] = f.description
			selected[f.name] = true
		end
		return [factorOrder, longFactorName, selectedFactors]
	end

	def self.getDefaultOrder 
		defOrder = DefaultFactorOrder.all
		df_hash = {}
		defOrder.each do |df|
			 df_hash[df.order] = df.name
		end
		df_hash = df_hash.sort.to_h
		return df_hash.values
	end

	def self.getFactors
		# Rails.cache.fetch("getFactors", expires_in: 24.hours) do
			ret = Array.new
			DefaultFactorOrder.find_each do |dfo|
				val = dfo.to_h
				if val["name"] == "study"
					factors = Array.new
					Study.find_each do |s|
						next unless s.active 
						factors << s.to_factor
					end
					val["factors"] = factors.sort_by(&:order).map(&:to_h)
				end
				ret << val
			end
			return ret
		# end
	end
end
