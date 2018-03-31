class ChangeFactorsInSharedSettings < ActiveRecord::Migration[5.1]
  def change
  	reversible do |dir|
      dir.up do
      	SharedSetting.connection.execute("ALTER TABLE shared_settings MODIFY factors json DEFAULT NULL;") 
      end
      dir.down do
        change_column :shared_settings, :factors, :string 
      end
    end  	
  end
end
