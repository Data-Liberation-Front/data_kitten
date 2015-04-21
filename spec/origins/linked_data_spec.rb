require 'spec_helper'

describe DataKitten::Origins::LinkedData do
    
    context "when detecting origin" do
    
        it "should ignore errors" do       
            FakeWeb.register_uri(:get, "http://example.org/not-found", :status => ["404", "Not Found"])            
            d = DataKitten::Dataset.new( access_url: "http://example.org/not-found")
            expect( d.origin ).to eql(nil)              
        end
        
        it "should support turtle" do
            FakeWeb.register_uri(:get, "http://example.org/doc/dataset", :body=>"", :content_type=>"text/turtle") 
            d = DataKitten::Dataset.new( access_url: "http://example.org/doc/dataset")   
            expect( d.origin ).to eql(:linkeddata)                           
        end        
        
    end
    
end
