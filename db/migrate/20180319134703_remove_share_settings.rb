class RemoveShareSettings < ActiveRecord::Migration[5.1]
  def change
  	drop_table :shared_settings
  end
end
