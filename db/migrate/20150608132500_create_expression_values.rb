class CreateExpressionValues < ActiveRecord::Migration[4.2]
  def change
    create_table :expression_values do |t|
      t.references :experiment, index: true, foreign_key: true
      t.references :gene, index: true, foreign_key: true
      t.references :meta_experiment, index: true, foreign_key: true
      t.references :type_of_value, index: true, foreign_key: true
      t.float :value

      t.timestamps null: false
    end
  end
end
