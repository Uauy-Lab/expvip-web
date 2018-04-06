require 'mongo'
module MongodbHelper
	def self.getConnectionConfiguration
		client_path = Rails.root.join('config', 'mongoid.yml')
		config_mongo = YAML.load_file(client_path)
		opts = config_mongo[ENV['RAILS_ENV']]["clients"]["default"]
		opts["options"]["database"] = opts["database"]
		Mongo::Logger.logger.level = Logger::WARN
		opts
	end

	def self.getConnection
		return @client if @client
		mongo_config = getConnectionConfiguration
		@client = Mongo::Client.new(
			mongo_config["hosts"],
			mongo_config["options"].to_options
			)
		@client
	end
end