class ChangeColumnUrl < ActiveRecord::Migration[5.1]
  def change
    rename_column :links, :URL, :url
  end
end
