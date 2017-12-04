class RemoveTissueFromExperiments < ActiveRecord::Migration[4.2]
  def change
    remove_reference :experiments, :tissue, index: true, foreign_key: true
  end
end
