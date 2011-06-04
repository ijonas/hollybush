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
      BSON::ObjectId.create_pk(entry)
      @entries << entry if List.coll.update({"_id" => make_id(@id)}, {"$push" => {:entries => entry}})
    end
    
    def delete_entry(entry)
      @entries.delete(entry) if List.coll.update({"_id" => make_id(@id)}, {"$pull" => {:entries => {"_id" => entry["_id"]}}})
    end
    
    def update_entry(entry)
      List.coll.update({"_id" => make_id(@id), "entries._id" => make_id(entry["_id"])}, {"$set" => {"entries.$"=> entry}})
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
      begin
        List.coll.remove(prepare(query))
      rescue BSON::InvalidObjectId
      end
    end

    def self.delete_entry(query = {})
      begin
        List.coll.remove(prepare(query))
      rescue BSON::InvalidObjectId
      end
    end

    
    def self.find(query = {}, options = {})
      begin
        coll.find(prepare(query), options).to_a.map {|doc| Hollybush::List.new(doc)}
      rescue BSON::InvalidObjectId => e
        puts e.message
        []
      end
    end
    
    def self.count(query = {})
      coll.find(query, :fields => []).count
    end
  
    private 
    def make_id(id)
      BSON::ObjectId.from_string(id)
    end

    def make_random_id
      BSON::ObjectId.from_string(id)
    end
    
    def self.coll
      $mongodb.collection(:list)
    end

    def self.prepare(query)
      ids = ["id", "_id", :id, :_id]
      new_bson_id = nil
      # we support querying by various incarnations of 'id' when in actual fact the query should be on '_id', so lets correct that
      ids.map do |id_key|
        if query.include?(id_key)
          new_bson_id = BSON::ObjectId.from_string(query[id_key])
          query.delete id_key
        end
      end
      query["_id"] = new_bson_id if new_bson_id
      query
    end
    
    
  end  
  
  
  
end