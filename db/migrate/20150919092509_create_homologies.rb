class CreateHomologies < ActiveRecord::Migration
  def change
    create_table :homologies do |t|
      t.references :Gene, index: true, foreign_key: true
      t.integer :Group
      t.string :Genome
      t.belongs_to :A, :class_name => "Gene"
  	  t.belongs_to :B, :class_name => "Gene"
  	  t.belongs_to :D, :class_name => "Gene"
      t.timestamps null: false
    end
  end
end
