class SampleGene < ApplicationRecord
  belongs_to :gene_set
  belongs_to :gene
end
