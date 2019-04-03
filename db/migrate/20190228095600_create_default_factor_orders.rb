class CreateDefaultFactorOrders < ActiveRecord::Migration[5.1]
  def change
    create_table :default_factor_orders do |t|
      t.string :name
      t.integer :order
    end
  end
end
