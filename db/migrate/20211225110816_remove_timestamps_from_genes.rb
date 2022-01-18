class RemoveTimestampsFromGenes < ActiveRecord::Migration[6.1]
  def change
    remove_column :genes, :created_at, :string
    remove_column :genes, :updated_at, :string
  end
end
