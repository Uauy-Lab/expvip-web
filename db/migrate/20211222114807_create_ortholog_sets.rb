class CreateOrthologSets < ActiveRecord::Migration[6.1]
  def change
    create_table :ortholog_sets do |t|
      t.string :name
      t.string :description

      t.timestamps
    end
  end
end
