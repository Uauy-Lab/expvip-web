class CreateHomologies < ActiveRecord::Migration[4.2]
  def change
    create_table :homologies do |t|
      t.references :gene, index: true, foreign_key: true
      t.integer :group
      t.string :genome
      t.belongs_to :A, :class_name => "Gene"
  	  t.belongs_to :B, :class_name => "Gene"
  	  t.belongs_to :D, :class_name => "Gene"
      t.timestamps null: false
    end
  end
end
