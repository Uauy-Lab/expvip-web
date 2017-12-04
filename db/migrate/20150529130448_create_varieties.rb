class CreateVarieties < ActiveRecord::Migration[4.2]
  def change
    create_table :varieties do |t|
      t.string :name
      t.string :description
      t.string :url

      t.timestamps null: false
    end
  end
end
