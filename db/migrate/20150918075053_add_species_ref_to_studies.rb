class AddSpeciesRefToStudies < ActiveRecord::Migration
  def change
    add_reference :studies, :species, index: true, foreign_key: true
  end
end
