class CreateExpressionBiasValues < ActiveRecord::Migration[5.1]
  def change
    create_table :expression_bias_values do |t|
      t.integer :decile
      t.float :min
      t.float :max
      t.references :expression_bias, foreign_key: true

      t.timestamps
    end
  end
end
