MongoMapper.connection = Mongo::Connection.new('127.0.0.1', 27017)
MongoMapper.database = "suite-#{Rails.env}"
MongoMapper.ensure_indexes!