module HomologyHelper
	def self.getHomologueGenesForGene(transcripts_in_gene)
		ret = Set.new
		transcripts_in_gene.each do |t|
			HomologyPair.where("gene_id = :gene_id", { gene_id: t.id }).each do |h|
				hom = h.homology
				HomologyPair.where("homology = :hom", { hom: hom }).each do |h2|
					if h2.gene.gene_set_id == t.gene_set_id
						ret << h2.gene.gene unless h2.gene == t.gene
					end
				end
			end
		end
		ret
	end

	def self.getValuesForHomologueGenes(gene_name, transcripts, gene_set)
		values = Hash.new
		values[gene_name] = ExpressionValuesHelper.getValuesForTranscripts(transcripts)
		homs = getHomologueGenesForGene(transcripts)
		puts homs.inspect
		homs.each do |e|
			values[e] = ExpressionValuesHelper.getValuesForTranscripts(GenesHelper.findTranscripts(e, gene_set))
		end
		return values
	end


end