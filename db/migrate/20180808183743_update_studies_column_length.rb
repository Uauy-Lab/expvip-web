class UpdateStudiesColumnLength < ActiveRecord::Migration[5.1]
  def change
  	change_column :studies, :manuscript, :string, :limit => 500
  	change_column :studies, :summary, :string, :limit => 500
  	change_column :studies, :sra_description, :string, :limit => 500
  end
end
