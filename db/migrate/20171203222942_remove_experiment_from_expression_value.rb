class RemoveExperimentFromExpressionValue < ActiveRecord::Migration[5.1]
  def change
  	remove_reference :expression_values, :experiment, index:true, foreign_key: true
    #remove_column :expression_values, :experiment_id, :int
  end
end
