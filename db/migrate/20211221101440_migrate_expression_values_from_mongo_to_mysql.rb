class MigrateExpressionValuesFromMongoToMysql < ActiveRecord::Migration[6.1]
  def up
    client = MongodbHelper.getConnection
    exps = client[:experiments]
    i = 0
    ActiveRecord::Base.transaction do
      ExpressionValue.find_each do |ev|
        obj = exps.find({ :_id => ev.id }).first
        obj.delete("_id")
        ev.values = obj
        i += 1
        ev.save!
        puts "migrated #{i} values " if i  % 10000 == 0
      end
      puts "DONE migrated #{i} values "
    end
  end
end
