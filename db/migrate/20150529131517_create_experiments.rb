class CreateExperiments < ActiveRecord::Migration
  def change
    create_table :experiments do |t|
      t.references :variety, index: true, foreign_key: true
      t.references :tissue, index: true, foreign_key: true
      t.string :age
      t.string :stress
      t.string :accession, index:true 
      t.timestamps null: false
    end
  end
end
