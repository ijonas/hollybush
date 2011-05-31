require "rubygems"
require "bundler/setup"

require "mongo"
require "active_model"
require "active_support"
require "logger"

# log = Logger.new(STDOUT)
# log.level = Logger::DEBUG
# $mongodb = Mongo::Connection.new("localhost", 27017, :logger => log).db("hollybush")

$mongodb = Mongo::Connection.new.db("hollybush")


require File.expand_path(File.join(File.dirname(__FILE__), '/list'))
