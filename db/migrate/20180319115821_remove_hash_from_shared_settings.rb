class RemoveHashFromSharedSettings < ActiveRecord::Migration[5.1]
  def change
    remove_column :shared_settings, :hash, :string
  end
end
