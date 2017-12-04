class CreateExperimentGroups < ActiveRecord::Migration[4.2]
  def change
    create_table :experiment_groups do |t|
      t.string :name
      t.text :description
      t.timestamps null: false
    end

    create_join_table :experiment_groups, :experiments do |t|
    	t.index :experiment_id
    	t.index :experiment_group_id
    end

  end 
end
