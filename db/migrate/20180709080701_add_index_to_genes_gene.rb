class AddIndexToGenesGene < ActiveRecord::Migration[5.1]
  def change
    add_index :genes, :gene
    add_index :genes, :transcript
  end
end
