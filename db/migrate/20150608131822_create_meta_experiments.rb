class CreateMetaExperiments < ActiveRecord::Migration[4.2]
  def change
    create_table :meta_experiments do |t|
      t.string :name
      t.text :description
      t.references :gene_set, index: true, foreign_key: true

      t.timestamps null: false
    end
    add_index :meta_experiments, :name
  end
end
