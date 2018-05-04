class CreateSampleGenes < ActiveRecord::Migration[5.1]
  def change
    create_table :sample_genes do |t|
      t.integer :gene_set_id, foreign_key: true
      t.integer :gene_id, foreign_key: true
      t.string :kind

      t.timestamps
    end
  end
end
