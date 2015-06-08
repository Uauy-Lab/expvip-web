class AddDescriptionToGene < ActiveRecord::Migration
  def change
    add_column :genes, :description, :string
  end
end
