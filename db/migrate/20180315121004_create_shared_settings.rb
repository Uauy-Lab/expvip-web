class CreateSharedSettings < ActiveRecord::Migration[5.1]
  def change
    create_table :shared_settings do |t|
      t.string :hash
      t.string :gene_set
      t.string :factors
    end
  end
end
