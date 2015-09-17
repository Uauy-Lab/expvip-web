class RemoveAgeFromExperiments < ActiveRecord::Migration
  def change
    remove_column :experiments, :age, :string
  end
end
