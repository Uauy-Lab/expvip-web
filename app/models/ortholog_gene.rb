class OrthologGene < ApplicationRecord
  belongs_to :OrthologGroup
  belongs_to :Gene
end
