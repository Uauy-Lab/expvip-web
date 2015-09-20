class Study < ActiveRecord::Base 
	belongs_to :species
	has_many :experiment_groups
end
