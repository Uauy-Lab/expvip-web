class RemoveSpecoesFromStudy < ActiveRecord::Migration
  def change
    remove_reference :studies, :species, index: true, foreign_key: true
  end
end
