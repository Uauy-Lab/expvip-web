class AddGeneSetNameToSampleGenes < ActiveRecord::Migration[5.1]
  def change
  	add_column :sample_genes, :gene_set_name, :string
  end
end
