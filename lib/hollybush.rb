require "rubygems"
require "bundler/setup"

require "mongo"

$mongodb = Mongo::Connection.new.db("hollybush")
require File.expand_path(File.join(File.dirname(__FILE__), '/list'))
