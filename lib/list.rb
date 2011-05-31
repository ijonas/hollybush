module Hollybush
  
  class List
    include Enumerable
    include ActiveModel::Validations
    include ActiveModel::Conversion
    extend ActiveModel::Naming
    
    attr_accessor :id, :name, :entries
    validates_presence_of :name
    
    def initialize(attributes = {})
      attributes.each do |name, value|
        send("#{name}=", value) if respond_to?(name)
      end
      @entries = [] unless @entries      
      @id = attributes["_id"].to_s if attributes.include?("_id")
    end
    
    def save
      update_doc = {:name => @name, :entries => @entries}
      if @id
        List.coll.update({"_id" => make_id(@id)}, update_doc)
      else
        @id = List.coll.save(update_doc).to_s
      end
    end
    
    def each(&a_block)
      doc = List.coll.find_one({"_id" => @id})
      doc["entries"].each(&a_block) if doc["entries"] 
    end
    
    def <<(entry)
      save unless persisted?
      @entries << entry if List.coll.update({"_id" => make_id(@id)}, {"$push" => {:entries => entry}})
    end
    
    def delete(entry)
      @entries.delete(entry) if List.coll.update({"_id" => make_id(@id)}, {"$pull" => {:entries => entry}})
    end
    
    def persisted?
      @id != nil
    end
    
    def self.find(query = {}, options = {})
      query["_id"] = BSON::ObjectId.from_string(query["_id"]) if query.include?("_id")
      coll.find(query, options).to_a.map {|doc| Hollybush::List.new(doc)}
    end
  
    private 
    def make_id(id)
      BSON::ObjectId.from_string(id)
    end
    
    def self.coll
      $mongodb.collection(:list)
    end
    
  end  
  
  
  
end