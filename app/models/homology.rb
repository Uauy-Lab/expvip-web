class Homology < ActiveRecord::Base
  belongs_to :Gene
  belongs_to :A, :class_name => "Gene"
  belongs_to :B, :class_name => "Gene"
  belongs_to :D, :class_name => "Gene"
end
