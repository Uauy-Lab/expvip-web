class RemoveTableTissue < ActiveRecord::Migration[6.1]
  def change
    drop_table :tissues
    drop_table :varieties
  end
end
