class CreateTypeOfValues < ActiveRecord::Migration
  def change
    create_table :type_of_values do |t|
      t.string :name
      t.text :description

      t.timestamps null: false
    end
    add_index :type_of_values, :name
  end
end
