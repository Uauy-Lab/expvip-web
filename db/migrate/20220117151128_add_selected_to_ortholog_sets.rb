class AddSelectedToOrthologSets < ActiveRecord::Migration[6.1]
  def change
    add_column :ortholog_sets, :selected, :boolean, :default => false
  end
end
