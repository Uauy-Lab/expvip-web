class Experiment < ActiveRecord::Base
	belongs_to :study
	#has_and_belongs_to_many :experiment_groups
	has_and_belongs_to_many :factors
end
