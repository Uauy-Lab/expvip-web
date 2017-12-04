class ExperimentGroup < ActiveRecord::Base
	 has_and_belongs_to_many :experiments
	 has_and_belongs_to_many :factors, join_table: "ExperimentGroups_Factors",  foreign_key: "ExperimentGroup_id", primary_key: "Factor_id"
end
