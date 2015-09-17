class RemoveStressFromExperiments < ActiveRecord::Migration
  def change
    remove_column :experiments, :stress, :string
  end
end
