require 'mongo'
module MongodbHelper
	def self.getConnection
		#This needs to be improved to be dynamic from the mongoid.yml
		client = Mongo::Client.new([ '127.0.0.1:27017' ], :database => "testdb")
		client
	end
end