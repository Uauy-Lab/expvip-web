class GeneSet < ActiveRecord::Base
	has_many :genes

	def to_h
		genes = Hash.new
		Gene.find_by_sql("SELECT * FROM genes where gene_set_id='#{self.id}' ORDER BY gene").each do |g|
			genes[g.name] = g unless genes[g.name]
		end
		genes
	end
end
