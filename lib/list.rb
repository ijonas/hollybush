module Hollybush
  
  class List
    include Enumerable
    attr_accessor :id, :name
    
    def initialize(options = {})
      @name = options[:name] if options.include?(:name)
      @id = options[:id] if options.include?(:id)      
      @coll = $mongodb.collection(:list)
    end
    
    def save
      @id = @coll.save({:name => @name})
    end
    
    def each(&a_block)
      doc = @coll.find_one({"_id" => @id})
      doc["entries"].each(&a_block) if doc["entries"] 
    end
    
    def <<(entry)
      save unless @id
      @coll.update({"_id" => @id}, {"$push" => {:entries => entry}})
    end
    
    def delete(entry)
      @coll.update({"_id" => @id}, {"$pull" => {:entries => entry}})
    end
    
    def self.find(query = {})
      $mongodb.collection(:list).find(query).to_a.map { |doc| List.new(doc) }
    end
  end  
  
end