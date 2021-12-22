class OrthologGroup < ApplicationRecord
  belongs_to :ortholog_set
  has_and_belongs_to_many :genes
end
