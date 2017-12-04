class CreateJoinTableExperimentGroupsFactors < ActiveRecord::Migration[4.2]
  def change
    create_join_table :ExperimentGroups, :Factors do |t|
      # t.index [:experiment_group_id, :factor_id]
      # t.index [:factor_id, :experiment_group_id]
    end
  end
end
