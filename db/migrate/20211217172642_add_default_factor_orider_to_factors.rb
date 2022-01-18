class AddDefaultFactorOriderToFactors < ActiveRecord::Migration[6.1]
  def change
    add_reference :factors, :default_factor_order, foreign_key: true
  end
end
