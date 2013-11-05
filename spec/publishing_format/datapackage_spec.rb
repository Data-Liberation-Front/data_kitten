require 'spec_helper'

#This is required to specify a load_file function which currently
#is only available on git origin
#
#Supply a prefix to separate out test filesTes
class DataPackageTestDataset < DataKitten::Dataset
    
    def initialize( options )
        @prefix = options[:prefix]
        super        
    end
    
    def load_file(file)
        File.read( File.join( File.dirname(File.realpath(__FILE__)) , "#{@prefix}#{file}" ) )
    end
    
end

describe DataKitten::PublishingFormats::Datapackage do
    
    context "when detecting format" do
        
        it "should detect datapackage.json" do
            d = DataPackageTestDataset.new(:access_url => "http://example.org")                    
            expect( d.publishing_format ).to eql(:datapackage)                 
        end

        it "should not be a data package if there is no datapackage.json" do
            d = DataPackageTestDataset.new(:access_url => "http://example.org", 
                :prefix => "missing")        
            expect( d.publishing_format ).to eql(nil)                 
        end        
                
    end
    
    context "when reading a basic datapackage.json file" do
        
        before(:each) do 
            @dataset = DataPackageTestDataset.new(:access_url => "http://example.org")
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
            expect( @dataset.rights).to eql([])            
        end
        
        it "should extract keywords" do
            expect( @dataset.keywords.length ).to eql(3)
            expect( @dataset.keywords ).to eql( ["data", "finances", "spending"] )
        end
        
    end
    
    context "when reading rights information" do
        
        before(:each) do 
            @dataset = DataPackageTestDataset.new(
                :access_url => "http://example.org", :prefix=>"odrs-")
            @rights = @dataset.rights().first
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