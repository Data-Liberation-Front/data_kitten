require 'spec_helper'

describe DataKitten::PublishingFormats::Datapackage do
    
    context "when detecting format" do
            
        it "should detect datapackage.json" do
            FakeWeb.register_uri(:get, "http://example.org/dataset/datapackage.json", :body=> load_fixture("datapackage.json") ) 
            d = DataKitten::Dataset.new(:access_url => "http://example.org/dataset/datapackage.json")                    
            expect( d.publishing_format ).to eql(:datapackage)                 
        end

        it "should not be a data package if there is no datapackage.json" do
            FakeWeb.register_uri(:get, "http://example.org/not-a-dataset/datapackage.json", :body=>"", :status => ["404", "Not Found"])   
            d = DataKitten::Dataset.new(:access_url => "http://example.org/not-a-dataset/datapackage.json")        
            expect( d.publishing_format ).to eql(nil)                 
        end        
                
    end
    
    context "when reading a basic datapackage.json file" do
        
        before(:each) do 
          FakeWeb.register_uri(:get, "http://example.org/dataset/datapackage.json", :body=> load_fixture("datapackage.json") ) 
          @dataset = DataKitten::Dataset.new(:access_url => "http://example.org/dataset/datapackage.json")      
        end
        
        it "should parse basic metadata" do
            expect( @dataset.data_title ).to eql("Test Dataset")
            expect( @dataset.description ).to eql("This is a test dataset")
        end
        
        it "should extract sources" do
            expect( @dataset.sources.length ).to eql(1)
            source = @dataset.sources.first
            expect( source.name ).to eql("Somewhere Else")
            expect( source.web ).to eql("http://data.example.org/123")
        end
        
        it "should extract licenses" do
            expect( @dataset.licenses.length ).to eql(1)
            license = @dataset.licenses.first
            expect( license.id ).to eql("odc-pddl")
            expect( license.uri ).to eql("http://opendatacommons.org/licenses/pddl/")
            expect( @dataset.rights).to eql(nil)            
        end
        
        it "should extract keywords" do
            expect( @dataset.keywords.length ).to eql(3)
            expect( @dataset.keywords ).to eql( ["data", "finances", "spending"] )
        end
   
        it "should extract modification date" do
            expect( @dataset.modified).to_not eql(nil)
        end
    end
    
    context "when reading rights information" do
        
        before(:each) do 
          FakeWeb.register_uri(:get, "http://example.org/dataset/datapackage.json", :body=> load_fixture("odrs-datapackage.json") ) 
          @dataset = DataKitten::Dataset.new(:access_url => "http://example.org/dataset/datapackage.json")  
          @rights = @dataset.rights()
        end        
        
        it "should extract licenses" do
            expect( @rights.contentLicense ).to eql("http://reference.data.gov.uk/id/open-government-licence")
            expect( @rights.dataLicense ).to eql("http://reference.data.gov.uk/id/open-government-licence")
        end

        it "should extract attribution details" do
            expect( @rights.attributionURL).to eql("http://gov.example.org/dataset/example")
            expect( @rights.attributionText).to eql("Example Department")
        end
    end
    
    
end