class ExpressionValue < ActiveRecord::Base
  belongs_to :experiment
  belongs_to :gene
  belongs_to :meta_experiment
  belongs_to :type_of_value
end
