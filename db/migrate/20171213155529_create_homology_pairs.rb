class CreateHomologyPairs < ActiveRecord::Migration[5.1]
  def change
    create_table :homology_pairs do |t|
      t.integer :homology
      t.string :cigar
      t.decimal :perc_cov, precision: 7, scale: 4
      t.decimal :perc_id, precision: 7, scale: 4
      t.decimal :perc_pos, precision: 7, scale: 4
      t.references :gene, index: true#, foreign_key: true

      t.timestamps
    end
    add_index :homology_pairs, :homology
  end
end
