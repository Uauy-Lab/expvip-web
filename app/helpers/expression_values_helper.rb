module ExpressionValuesHelper
	#This function needs to be updated to get from different experiments
	#for simplicty and as initial test we only filter by type of value
	def self.getValuesTable(expressionUnit:)
		#puts "getting values: #{expressionUnit}"
		headers = Array.new
		values = Array.new
		count = 0
		last_gene = ""
		ExpressionValue.find_expressions_for_unit(expressionUnit) do |row|
				current_gene = row[0]
				last_gene = row[0] if last_gene == ""
				if(count == 0 and  current_gene == last_gene)
					headers << row[1]
				end
				if(current_gene != last_gene)
					values.unshift(last_gene)
					headers.unshift("")
					yield headers if count == 0
					yield values
					values = Array.new
					puts "#{count} genes done" if count % 1000 == 0

					count += 1
				end
				values << row[2]
				last_gene = current_gene
				

		end
		puts "#{count} genes exported" 
	end

	def self.add(row, genes, experiments, meta_exp, value_type, accession) 
		gene_name = row["target_id"]
		gene_name = row["transcript"] unless row["target_id"]
		gene = genes[gene_name]
		if row.headers.include? "est_counts" and row.headers.include? "tpm"
			h_row = {accession => row["est_counts"]} if value_type.name == 'count'
			h_row = {accession => row["tpm"]} if value_type.name == 'tpm'
		else
			h_row = row.to_hash
		end
		to_insert_h = Hash.new
		missing = Set.new
		h_row.each_pair do |name, val|
			exp_id = experiments[name]
			missing << name unless exp_id
			to_insert_h[exp_id] = val.to_f if exp_id
		end
		
		exp_val = ExpressionValue.find_or_create_by( 
			:gene =>  gene, 
			:meta_experiment => meta_exp ,
			:type_of_value => value_type )
		exp_val.values = to_insert_h if to_insert_h.size > 0

		#TODO: Add values if they exist
		exp_val.save!
#		ExperimentsHelper.saveValues(exp_val, to_insert_h) 
		missing
	end

	def self.migrate_from_mongodb
		client = MongodbHelper.getConnection
		exps = client[:experiments]
		i = 0
		ActiveRecord::Base.transaction do
			ExpressionValue.find_each do |ev|
				obj = exps.find({ :_id => ev.id }).first
				obj.delete("_id")
				ev.values = obj
				i += 1
				ev.save!
				puts "migrated #{i} values " if i  % 10000 == 0
			#	puts ev.inspect
				#break if i  % 10 == 0
			end
			puts "DONE migrated #{i} values "
		end
  	end

	def self.getValuesForTranscripts(transcripts_in_gene)
		values = Hash.new { |hash, key| hash[key] = Hash.new { |h, k| h[k] = 0 } }
		transcripts_in_gene.each do |t|
			v_t = getValuesForTranscript(t)
			v_t.each_pair do |type, h|
				h.each_pair do |exp, val|
					current = values[type][exp]
					current = { :experiment => exp, :value => 0.0 } if current == 0
					current[:value] += val[:value]
					values[type][exp] = current
				end
			end
		end
		values
	end

	def self.getValuesForTranscript(gene)
		#TODO: Add code to validate for different experiments.
		values = Hash.new
		ExpressionValue.where("gene_id = :gene", { gene: gene.id }).each do |ev|
			type_of_value = ev.type_of_value.name
			values[type_of_value] = Hash.new unless values[type_of_value]
			obj = ev.values
			obj.each_pair { |k, val| 
				values[type_of_value][k.to_s] = { experiment: k, value: val } unless k == "_id" 
			} if obj
		end
		removeInactiveValues values
		return values
	end

	def self.removeInactiveValues(values)
		Experiment.joins(:study).where("studies.active = 0").each do |e|
			values.keys.each do |k|
			values[k].delete e.id.to_s
			end
		end
	end

	def self.getValuesForHomologuesTranscripts(gene)
		#TODO: This can go away, we should send the homologies from the client. 
		values = Hash.new
		values[gene.name] = getValuesForTranscript(gene)
		HomologyPair.where("gene_id = :gene", { gene: gene.id }).each do |h|
			hom = h.homology
			HomologyPair.where("homology = :hom", { hom: hom }).each do |h2|
				if h2.gene.gene_set_id == gene.gene_set_id
				values[h2.gene.name] = getValuesForTranscript(h2.gene) unless h2.gene == gene
				end
			end
		end
		return values
	end

end
