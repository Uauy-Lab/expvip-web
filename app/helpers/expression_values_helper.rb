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
					puts "#{count} genes done" if(count %1000 == 0)

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
		h_row = {accession => row["est_counts"]} if value_type.name == 'count'
		h_row = {accession => row["tpm"]} if value_type.name == 'tpm'
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
		exp_val.save!
		ExperimentsHelper.saveValues(exp_val, to_insert_h) if to_insert_h.size > 0
		missing
	end

end
