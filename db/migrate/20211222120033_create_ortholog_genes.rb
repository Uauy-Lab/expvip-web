class CreateOrthologGenes < ActiveRecord::Migration[6.1]
  def change
    # create_table :ortholog_genes do |t|
    #   t.references :ortholog_groups, null: false, foreign_key: true
    #   #t.references :genes, null: false, foreign_key: true, :integer
    #   t.integer :gene_id
    # end
    # add_foreign_key :ortholog_genes, :genes, column: :gene_id
    create_join_table :ortholog_groups, :genes
  end
end
