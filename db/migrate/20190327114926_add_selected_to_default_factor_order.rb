class AddSelectedToDefaultFactorOrder < ActiveRecord::Migration[5.1]
  def change
    add_column :default_factor_orders, :selected, :integer
  end
end
