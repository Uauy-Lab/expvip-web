class Experiment < ActiveRecord::Base
  belongs_to :variety
  belongs_to :tissue
  belongs_to :study
  has_and_belongs_to_many :experiment_groups
end
