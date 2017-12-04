class CreateFactors < ActiveRecord::Migration[4.2]
  def change
    create_table :factors do |t|
      t.string :name
      t.text :description
      t.integer :order

      t.timestamps null: false
    end
  end
end
