class AddGeneSetToGene < ActiveRecord::Migration[4.2]
  def change
    add_reference :genes, :gene_set, index: true, foreign_key: true
  end
end
