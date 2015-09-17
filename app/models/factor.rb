class Factor < ActiveRecord::Base
	has_and_belongs_to_many :experiment_groups
end
