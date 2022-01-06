class DefaultFactorOrder < ActiveRecord::Base
	has_many :factors, class_name: "Factor", foreign_key: "default_factor_order_id"
	
	def to_h
		ret = Hash.new 
		ret["name"] = self.name
		ret["order"] = self.order 
		ret["selected"] = self.selected
		factors = Array.new
		self.factors.each do |factor|
			factors << factor
		end
		ret["factors"] = factors.sort_by(&:order).map(&:to_h)
		return ret 
	end
end

