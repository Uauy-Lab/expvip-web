class RemoveFactorColumn < ActiveRecord::Migration[6.1]
  def change
    remove_column :factors, :factor
  end
end
