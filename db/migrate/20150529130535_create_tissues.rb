class CreateTissues < ActiveRecord::Migration
  def change
    create_table :tissues do |t|
      t.string :name
      t.string :description

      t.timestamps null: false
    end
  end
end
