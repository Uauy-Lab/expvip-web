class Homology < ActiveRecord::Base
  belongs_to :gene
  belongs_to :A, :class_name => "Gene"
  belongs_to :B, :class_name => "Gene"
  belongs_to :D, :class_name => "Gene"

  def total
  	count = 0
  	count += 1 if self.A
  	count += 1 if self.B
  	count += 1 if self.D
  	return count
  end

end
