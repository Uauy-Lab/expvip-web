class Factor < ActiveRecord::Base
	has_and_belongs_to_many :experiment_groups, join_table:  "ExperimentGroups_Factors"
	belongs_to :default_factor_order, class_name: "DefaultFactorOrder", foreign_key: "default_factor_order_id"
	
	def factor
		default_factor_order.name
	end
end
