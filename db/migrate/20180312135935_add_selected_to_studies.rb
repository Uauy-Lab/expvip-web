class AddSelectedToStudies < ActiveRecord::Migration[5.1]
  def change
    add_column :studies, :selected, :boolean
  end
end
