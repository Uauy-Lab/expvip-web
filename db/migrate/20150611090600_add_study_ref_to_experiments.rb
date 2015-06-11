class AddStudyRefToExperiments < ActiveRecord::Migration
  def change
    add_reference :experiments, :study, index: true, foreign_key: true
  end
end
