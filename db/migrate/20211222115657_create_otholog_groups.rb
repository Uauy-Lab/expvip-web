class CreateOthologGroups < ActiveRecord::Migration[6.1]
  def change
    create_table :ortholog_groups do |t|
      t.references :ortholog_set, null: false, foreign_key: true

    end
  end
end
