class Factor < ActiveRecord::Base
	has_and_belongs_to_many :experiment_groups, join_table:  "ExperimentGroups_Factors"
	belongs_to :default_factor_order, class_name: "DefaultFactorOrder", foreign_key: "default_factor_order_id"
	
	def factor
		@@factor_names ||= Hash.new 
		@@factor_names[self.id] ||=  self.default_factor_order.name
		return @@factor_names[self.id]  
	end

	def to_h
		ret = Hash.new
		ret["name"] = self.name
		ret["description"] = self.description
		ret["order"] = self.order
		ret["selected"] = true
		return ret
	end

	def selected
		#TODO: maybe we want to add this as a real column
		return @selected if defined? @selected
		return true
	end

	def selected=(s)
		@selected=s
	end

end
