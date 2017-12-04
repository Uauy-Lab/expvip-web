class AddStudyRefToExperiments < ActiveRecord::Migration[4.2]
  def change
    add_reference :experiments, :study, index: true, foreign_key: true
  end
end
