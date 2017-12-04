class RemoveStressFromExperiments < ActiveRecord::Migration[4.2]
  def change
    remove_column :experiments, :stress, :string
  end
end
