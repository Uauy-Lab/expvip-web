class AddSelectedToGeneSets < ActiveRecord::Migration[5.1]
  def change
    add_column :gene_sets, :selected, :boolean
  end
end
