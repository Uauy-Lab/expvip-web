class AddColumnToSampleGenes < ActiveRecord::Migration[5.1]
  def change
  	add_column :sample_genes, :gene_name, :string
  end
end
