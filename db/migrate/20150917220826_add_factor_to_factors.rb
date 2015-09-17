class AddFactorToFactors < ActiveRecord::Migration
  def change
    add_column :factors, :factor, :string
    add_index :factors, :factor
  end
end
