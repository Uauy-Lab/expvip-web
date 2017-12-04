class AddDescriptionToGene < ActiveRecord::Migration[4.2]
  def change
    add_column :genes, :description, :string
  end
end
