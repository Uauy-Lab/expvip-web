class ChangeDataTypeForDescription < ActiveRecord::Migration
  def change
    reversible do |dir|
      change_table :genes do |t|
        dir.up   { t.change :description, :text }
        dir.down { t.change :description, :string }
      end
      change_table :experiment_groups do |t|
        dir.up   { t.change :description, :text }
        dir.down { t.change :description, :string }
      end

      change_table :gene_sets do |t|
        dir.up   { t.change :description, :text }
        dir.down { t.change :description, :string }
      end

      change_table :tissues do |t|
        dir.up   { t.change :description, :text }
        dir.down { t.change :description, :string }
      end

      change_table :varieties do |t|
        dir.up   { t.change :description, :text }
        dir.down { t.change :description, :string }
      end


    end
  end
end
