class AddColumnToLinks < ActiveRecord::Migration[5.1]
  def change
    add_column :links, :site_name, :string
  end
end
