class CreateExpressionBias < ActiveRecord::Migration[5.1]
  def change
    create_table :expression_bias do |t|
      t.string :name
      t.integer :order

      t.timestamps
    end
  end
end
