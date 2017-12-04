class CreateSpecies < ActiveRecord::Migration[4.2]
  def change
    create_table :species do |t|
      t.string :name
      t.string :scientific_name
      t.timestamps null: false
    end
  end
end
