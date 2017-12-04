class RemoveVarietyFromExperiments < ActiveRecord::Migration[4.2]
  def change
    remove_reference :experiments, :variety, index: true, foreign_key: true
  end
end
