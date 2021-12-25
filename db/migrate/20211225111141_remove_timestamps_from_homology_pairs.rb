class RemoveTimestampsFromHomologyPairs < ActiveRecord::Migration[6.1]
  def change
    remove_column :homology_pairs, :created_at, :string
    remove_column :homology_pairs, :updated_at, :string
  end
end
