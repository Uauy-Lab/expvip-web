class CreateOrthologGenes < ActiveRecord::Migration[6.1]
  def change
    create_table :ortholog_genes do |t|
      t.references :ortholog_groups, null: false, foreign_key: true
      t.references :genes, null: false, foreign_key: true

    end
  end
end
