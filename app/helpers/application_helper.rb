module ApplicationHelper

	def reference_gene_sets()
		gene_sets = Array.new
		GeneSet.all.each do |gs|
			gene_sets << [gs.name, gs.id]
		end
		gene_sets
	end
end
