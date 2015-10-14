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

end
