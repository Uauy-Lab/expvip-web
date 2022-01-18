class AddColumnValuesToExpressionValue < ActiveRecord::Migration[6.1]
  def change
    add_column :expression_values, :values, :json
  end
end
