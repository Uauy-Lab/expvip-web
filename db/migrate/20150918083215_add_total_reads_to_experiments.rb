class AddTotalReadsToExperiments < ActiveRecord::Migration[4.2]
  def change
    add_column :experiments, :total_reads, :integer
    add_column :experiments, :mapped_reads, :integer
  end
end
