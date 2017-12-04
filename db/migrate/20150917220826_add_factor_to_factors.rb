class AddFactorToFactors < ActiveRecord::Migration[4.2]
  def change
    add_column :factors, :factor, :string
    add_index :factors, :factor
  end
end
