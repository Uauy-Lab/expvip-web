class AddIndexToGenes < ActiveRecord::Migration[4.2]
  def change
    add_index :genes, :name
  end
end
