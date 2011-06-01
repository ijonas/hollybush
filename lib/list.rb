module Hollybush
  
  class List
    include Enumerable
    include ActiveModel::Validations
    include ActiveModel::Conversion
    extend ActiveModel::Naming
    
    attr_accessor :id, :name, :entries
    validates_presence_of :name
    
    def initialize(attributes = {})
      update_attributes(attributes)
      @entries = [] unless @entries      
      @id = attributes["_id"].to_s if attributes.include?("_id")
    end
    
    def save
      if valid?
        update_doc = {:name => @name, :entries => @entries}
        if @id
          List.coll.update({"_id" => make_id(@id)}, update_doc)
        else
          @id = List.coll.save(update_doc).to_s
        end
      else
        false
      end
    end
    
    def self.create(attributes)
      list = List.new(attributes)
      list.save
      list
    end
    
    def each(&a_block)
      doc = List.coll.find_one({"_id" => @id})
      doc["entries"].each(&a_block) if doc["entries"] 
    end
    
    def <<(entry)
      save unless persisted?
      @entries << entry if List.coll.update({"_id" => make_id(@id)}, {"$push" => {:entries => entry}})
    end
    
    def delete_entry(entry)
      @entries.delete(entry) if List.coll.update({"_id" => make_id(@id)}, {"$pull" => {:entries => entry}})
    end
    
    def persisted?
      @id != nil
    end
    
    def update_attributes(attributes = {})
      attributes.each do |name, value|
        send("#{name}=", value) if respond_to?(name)
      end      
    end
    
    def delete
      List.coll.remove({"_id" => make_id(@id)})
    end
    
    def self.delete(query = {})
      List.coll.remove(prepare(query))
    end
    
    def self.find(query = {}, options = {})
      coll.find(prepare(query), options).to_a.map {|doc| Hollybush::List.new(doc)}
    end
    
    def self.count(query = {})
      coll.find(query, :fields => []).count
    end
  
    private 
    def make_id(id)
      BSON::ObjectId.from_string(id)
    end
    
    def self.coll
      $mongodb.collection(:list)
    end

    def self.prepare(query)
      query["_id"] = BSON::ObjectId.from_string(query["_id"]) if query.include?("_id")
      # we support querying by 'id' when in actual fact the query should be on '_id', so lets correct that
      if query.include?("id")
        query["_id"] = BSON::ObjectId.from_string(query["id"])
        query.delete "id"
      end
      query
    end
    
    
  end  
  
  
  
end