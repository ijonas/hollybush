require "rubygems"
require "bundler/setup"

require "mongo"
require "active_model"
require "active_support"
require "logger"

log = Logger.new(STDOUT)
log.level = Logger::DEBUG

uri = URI.parse(ENV['MONGOHQ_URL'])
conn = Mongo::Connection.new(uri.host, uri.port)
$mongodb = conn.db(uri.path.gsub(/^\//, ''))
$mongodb.authenticate(uri.user, uri.password)
# 
# $mongodb = Mongo::Connection.new("localhost", 27017, :logger => log).db("hollybush")

# $mongodb = Mongo::Connection.new.db("hollybush")



require File.expand_path(File.join(File.dirname(__FILE__), '/list'))
