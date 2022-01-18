class Gene < ActiveRecord::Base
	belongs_to :gene_set
	has_many :expression_values;
	has_many :type_of_value , through: :expression_values
	has_many :meta_experiment , through: :expression_values
	has_and_belongs_to_many :ortholog_groups
	def add_field(text)
		arr = text.split(":", 2)
		#puts arr.inspect
		arr[0] = "possition" if arr[0] == "scaffold" or arr[0] == "chromosome"
		arr.unshift("description") if arr.size == 1

		#puts arr.inspect
		self.send(arr[0]+'=',arr[1])
	end

	def to_s
		name
	end

	def full_gene_name
		"#{gene_set.name}:#{gene}"
	end

	def chromosome
		self.name[chrom_pos]
	end

	def genome 
		self.name[chrom_pos + 1]
	end

	def is_traes? #Following the IWGSC convention
		self.name.starts_with? "Traes"
	end

	def is_triae? #Following TGAC convention
		self.name.starts_with? "TRIAE_CS42"
	end

	def chrom_pos
		number_poistions = name.scan(/[[:digit:]]/)
		return name.index(number_poistions[2] )if self.is_triae?	
		return name.index(number_poistions[0])
	end

end
