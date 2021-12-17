class UpdateFactorToUseFactorOrder < ActiveRecord::Migration[6.1]
  
  def up
    Factor.all.each do |f|
      dfo = DefaultFactorOrder.find_by(name: f.factor)
      f.default_factor_order = dfo
      f.save!
    end
  end

  def down
    Factor.all.each do |f|
      f.default_factor_order = nil
      f.save!
    end
  end
  
end
