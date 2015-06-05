class Species < ActiveRecord::Base
	def to_s
		scientific_name
	end
end
