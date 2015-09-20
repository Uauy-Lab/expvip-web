class ExperimentGroup < ActiveRecord::Base
	 has_and_belongs_to_many :experiments
	 has_and_belongs_to_many :factors, join_table: "ExperimentGroups_Factors"
end
