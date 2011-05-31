require 'spec_helper'

module Hollybush
  
  describe List do
    context "when stored in the DB" do
      before(:each) do
        @list = List.new(:name => "My New List")
        @list.save
      end
      specify { @list.id.should_not be_nil }
      specify { @list.id.should be_an_instance_of(String) }
      specify { @list.name.should == "My New List" }
      
      context "when adding items into the list" do
        before(:each) do
          @list << {:description => "Here's an item"}
          @list << {:description => "Here's another item", :state => "Started"}
        end
        specify { @list.should have(2).entries }
        
        context "when deleting items from the list" do
          before(:each) do
            @list.delete({:description => "Here's an item"})
          end
          specify { @list.should have(1).entries }
        end
      end
    end
    
    context "when retrieving from the DB" do
      before(:each) do
        @list = List.new(:name => "My New List", "entries" => [{"description" => "Here's an item"}])
        @id = @list.save
      end
      specify { List.find.first.id.should == @list.id }
      specify { List.find("_id" => @id).first.id.should == @list.id }
    end
    
  end  
end
