module Hollybush
  unless defined?(@@mongodb) and @@mongodb 
    if ENV['MONGOHQ_URL']
      log = Logger.new(STDOUT)
      log.level = Logger::DEBUG

      uri = URI.parse(ENV['MONGOHQ_URL'])
      conn = Mongo::Connection.new(uri.host, uri.port)
      @@mongodb = conn.db(uri.path.gsub(/^\//, ''))
      @@mongodb.authenticate(uri.user, uri.password) unless uri.user.nil? or uri.user.empty?
    end
  end
  def self.mongodb=(mongodb)
    @@mongodb = mongodb
  end
  def self.mongodb
    unless defined?(@@mongodb) and @@mongodb 
      puts "PLEASE SPECIFY A MONGODB DATABASE OBJECT. Use Hollybush.mongodb="
      return nil
    end
    @@mongodb
  end
end