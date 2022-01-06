class Study < ActiveRecord::Base 
	belongs_to :species
	has_many :experiment_groups

	def to_factor
		ret = Factor.new
		ret.name = self.accession
		ret.description = self.title
		ret.order = self.order
		ret
	end
end
