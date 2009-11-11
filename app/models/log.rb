class Log
  include MongoMapper::Document
  
  key :type, String, :required => true
  key :resource, String
  key :activity, Hash
end