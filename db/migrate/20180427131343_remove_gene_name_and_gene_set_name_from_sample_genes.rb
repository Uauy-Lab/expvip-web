class RemoveGeneNameAndGeneSetNameFromSampleGenes < ActiveRecord::Migration[5.1]
  def change
  	remove_column :sample_genes, :gene_name
  	remove_column :sample_genes, :gene_set_name
  end
end
