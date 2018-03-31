class AddHashedFactorsToSharedSettings < ActiveRecord::Migration[5.1]
  def change
    add_column :shared_settings, :hashed_factors, :string
  end
end
