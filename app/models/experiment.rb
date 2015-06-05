class Experiment < ActiveRecord::Base
  belongs_to :variety
  belongs_to :tissue
  has_and_belongs_to_many :experiment_groups
end
