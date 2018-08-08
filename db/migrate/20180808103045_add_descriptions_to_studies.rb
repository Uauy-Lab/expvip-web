class AddDescriptionsToStudies < ActiveRecord::Migration[5.1]
  def change
  	add_column :studies, :summary, :string
  	add_column :studies, :sra_description, :string
  	add_column :studies, :grouping, :string
  	add_column :studies, :doi, :string
  	add_column :studies, :order, :integer
  	add_column :studies, :active, :boolean
  end
end
