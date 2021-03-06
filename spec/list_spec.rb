require 'spec_helper'

module Hollybush
  
  describe List do
    context "when storing in the DB with valid details" do
      before(:each) do
        @list = List.new(:name => "My New List")
        @list.save
      end
      it "should have an id" do
        @list.id.should_not be_nil
      end
      it "id should be of a String type" do
        @list.id.should be_an_instance_of(String)
      end
      it "should have a name" do
        @list.name.should == "My New List"
      end
      specify {@list.should be_valid}      
      context "when adding items into the list" do
        before(:each) do
          @list << {:description => "Here's an item"}
          @list << {:description => "Here's another item", :state => "Started"}
        end
        specify { @list.should have(2).entries }
        
        context "when deleting items from the list" do
          before(:each) do
            @list.delete_entry(@list.entries.first)
          end
          specify { @list.should have(1).entries }
        end
        
        context "when updating an item" do
          before(:each) do
            entry = @list.entries.first
            entry["description"] = "Here's an updated entry"
            @list.save
            @updated_list = List.find(:_id => @list.id).first
          end
          it "should update an existing entry" do
            @updated_list.entries.first["description"].should == "Here's an updated entry"
          end
          it "should not create or remove Lists" do
            expect { @list.save }.not_to change(List, :count)
          end
          it "should not create or remove Entries in the Lists" do
            @updated_list.should have(2).entries
          end
        end
      end
    end
    
    context "when storing in the DB with invalid details" do
      before(:each) do
        @list = List.new(:name => nil)
        @list.save
      end
      specify {@list.should_not be_valid}
      it "should have an id" do
        @list.id.should be_nil
      end
      it "should have an error on 'name'" do
        @list.errors[:name].should == ["can't be blank"]
      end
    end
    
    context "when updating a List" do
      before(:each) do
        @list = List.new(:name => "My New List")
        @list.save
      end
      context "with valid details" do
        before(:each) do
          @list.name = "My Revised List"
          @list.save
        end
        specify {@list.should be_valid}
        it "should persist on save" do
          List.find({"id" => @list.id}).first.name.should == "My Revised List"
        end
      end
      context "with invalid details" do
        before(:each) do
          @list.name = nil
          @list.save          
        end
        specify {@list.should_not be_valid}
        it "should leave persisted version of List unaffected" do
          List.find({"id" => @list.id}).first.name.should == "My New List"
        end
        it "should have an error on 'name'" do
          @list.errors[:name].should == ["can't be blank"]
        end        
      end
      context "with an attribute hash" do
        before(:each) do
          @list = List.create(:name => "My New List")
          @attributes = {"name"=>"My Revised Shopping List", "entries" => [{"description"=>"entry 1"},{"description"=>"entry 2"}], "id"=>@list.id, "controller"=>"lists", "action"=>"update"}
          @list.update_attributes(@attributes)
          @list.save
        end
        specify{ @list.should be_valid }
        it "should update the persisted version with name and entries" do
          list = List.find({"id" => @list.id}).first
          list.name.should == @attributes["name"]
          list.entries.should =~ @attributes["entries"]
        end
      end
      
    end
    
    context "when retrieving from the DB" do
      before(:each) do
        @list = List.new(:name => "My New List", "entries" => [{"description" => "Here's an item"}])
        @id = @list.save
        List.new(:name => "My Second List", "entries" => [{"description" => "Here's another item"}]).save
      end
      it "should retrieve all lists by specifying no parameters" do
        List.find.should have(2).entries
      end
      it "should retrieve specific lists by specifying some parameters" do
        List.find("_id" => @id).first.id.should == @list.id
      end
    end
    
    context "when deleting Lists" do
      before(:each) do
        @list1 = List.create(:name => "My first list")
        @list2 = List.create(:name => "My second list")
      end
      context "deleting a single list" do
        it "should reduce the List count by 1" do
          expect { @list1.delete }.to change(List, :count).by(-1)
        end
      end
      context "deleting Lists based on matching criteria" do
        it "should reduce the List count by 2" do
          expect { List.delete({:name => /My/}) }.to change(List, :count).by(-2)
        end
      end
      context "deleting Lists based on non-matching criteria" do
        it "should not reduce the List count" do
          expect { List.delete({:name => /You/}) }.to_not change(List, :count)
        end
      end
    end
    
  end  
end
