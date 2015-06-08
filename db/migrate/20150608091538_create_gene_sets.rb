class CreateGeneSets < ActiveRecord::Migration
  def change
    create_table :gene_sets do |t|
      t.string :name
      t.string :description

      t.timestamps null: false
    end
  end
end
