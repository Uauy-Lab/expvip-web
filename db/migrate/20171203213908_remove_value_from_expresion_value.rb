class RemoveValueFromExpresionValue < ActiveRecord::Migration[5.1]
  def change
    remove_column :expression_values, :value, :float
  end
end
