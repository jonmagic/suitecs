RAILS_GEM_VERSION = '2.2.2' unless defined? RAILS_GEM_VERSION
require File.join(File.dirname(__FILE__), 'boot')
Rails::Initializer.run do |config|
  config.time_zone = 'Eastern Time (US & Canada)'
  config.action_controller.session = {
    :session_key => '_bort_session',
    :secret      => 'c9ba017060e99fd4e23621a963dfe5d05e7975c732e622924b4a9b86a6b6d60ca6c067429f937c06675480f3181fc39f0d5328a73b559c3879cc2d9bee662c9d'
  }
  config.action_controller.session_store = :active_record_store
  config.active_record.observers = :user_observer
  config.gem 'googlebase', :lib => 'google/base', :version => '0.2.1'
  config.gem 'paperclip', :version => '2.1.2'
  config.gem "jnunemaker-httparty", :lib => 'httparty'
  config.gem "RedCloth", :lib => "redcloth"
  config.gem "dcparker-days_and_times", :lib => 'days_and_times', :version => '1.0.0'
  config.gem "quickbooks"
  config.gem 'mongo_mapper', :version => '>= 0.6.1'
  require 'lib/search.rb'
  require 'lib/statuslang.rb'
end
MongoMapper.connection = Mongo::Connection.new('127.0.0.1', 27017, :auto_reconnect => true, :logger => Rails.logger)
MongoMapper.database = "suite-#{Rails.env}"
MongoMapper.ensure_indexes!