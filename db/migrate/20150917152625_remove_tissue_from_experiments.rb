class RemoveTissueFromExperiments < ActiveRecord::Migration
  def change
    remove_reference :experiments, :tissue, index: true, foreign_key: true
  end
end
