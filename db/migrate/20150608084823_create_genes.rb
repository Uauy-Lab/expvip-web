class CreateGenes < ActiveRecord::Migration
  def change
    create_table :genes do |t|
      t.string :name
      t.string :cdna
      t.string :possition
      t.string :gene
      t.string :transcript

      t.timestamps null: false
    end
  end
end
