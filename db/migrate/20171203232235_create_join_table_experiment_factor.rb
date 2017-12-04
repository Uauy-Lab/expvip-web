class CreateJoinTableExperimentFactor < ActiveRecord::Migration[5.1]
  def change
    create_join_table :experiments, :factors do |t|
       t.index [:experiment_id, :factor_id]
      # t.index [:factor_id, :experiment_id]
    end
  end
end
