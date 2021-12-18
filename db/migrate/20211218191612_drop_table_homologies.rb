class DropTableHomologies < ActiveRecord::Migration[6.1]
  def change
    drop_table :homologies
  end
end
