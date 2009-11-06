class Log
  include MongoMapper::Document
  
  key :type, String, :required => true
  key :activity, Hash
end