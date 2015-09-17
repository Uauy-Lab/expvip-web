class RemoveVarietyFromExperiments < ActiveRecord::Migration
  def change
    remove_reference :experiments, :variety, index: true, foreign_key: true
  end
end
