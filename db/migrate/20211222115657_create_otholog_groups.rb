class CreateOthologGroups < ActiveRecord::Migration[6.1]
  def change
    create_table :otholog_groups do |t|
      t.references :ortholog_set, null: false, foreign_key: true

    end
  end
end
