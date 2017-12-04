class RemoveAgeFromExperiments < ActiveRecord::Migration[4.2]
  def change
    remove_column :experiments, :age, :string
  end
end
