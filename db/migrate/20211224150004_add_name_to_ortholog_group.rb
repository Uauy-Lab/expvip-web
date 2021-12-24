class AddNameToOrthologGroup < ActiveRecord::Migration[6.1]
  def change
    add_column :ortholog_groups, :name, :string
  end
end
