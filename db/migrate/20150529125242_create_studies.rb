class CreateStudies < ActiveRecord::Migration[4.2]
  def change
    create_table :studies do |t|
      t.string :accession, index:true
      t.references :species, index: true, foreign_key: true
      t.string :title, index: true, foreign_key: true
      t.string :manuscript

      t.timestamps null: false
    end
  end
end
