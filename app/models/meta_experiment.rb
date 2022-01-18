class MetaExperiment < ActiveRecord::Base
  belongs_to :gene_set
  #has_many :value
end
