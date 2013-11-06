require 'spec_helper'

describe DataKitten::PublishingFormats::RDFa do

    before(:all) do
        FakeWeb.clean_registry
        FakeWeb.allow_net_connect = false
    end
    
    context "when detecting RDFa" do
        
        it "should ignore errors" do       
            FakeWeb.register_uri(:get, "http://example.org/not-found", :status => ["404", "Not Found"])            
            d = DataKitten::Dataset.new( access_url: "http://example.org/not-found")        
            expect( d.supported? ).to eql(false)        
        end

        it "should detect DCAT Datasets" do
            dcat_rdfa = File.read( File.join( File.dirname(File.realpath(__FILE__)) , "basic-dcat-rdfa.html" ) )         
            FakeWeb.register_uri(:get, "http://example.org/rdfa", :body=>dcat_rdfa, :content_type=>"text/html")            
            d = DataKitten::Dataset.new( access_url: "http://example.org/rdfa")
            expect( d.publishing_format ).to eql(:rdfa)        
            expect( d.supported? ).to eql(true)                    
        end
    end
    
    context "when parsing RDFa" do
        
        before(:each) do
            dcat_rdfa = File.read( File.join( File.dirname(File.realpath(__FILE__)) , "basic-dcat-rdfa.html" ) )         
            FakeWeb.register_uri(:get, "http://example.org/rdfa", :body=>dcat_rdfa, :content_type=>"text/html")            
            @dataset = DataKitten::Dataset.new( access_url: "http://example.org/rdfa")        
        end        
        
        it "should extract the title" do
            expect( @dataset.data_title ).to eql("Example DCAT Dataset")              
        end

        it "should extract the description" do
            expect( @dataset.description ).to eql("This is the description.")              
        end
        
        it "should extract licenses" do
            expect( @dataset.licenses.length ).to eql(1)
            licence = @dataset.licenses.first
            expect( licence.uri ).to eql("http://reference.data.gov.uk/id/open-government-licence")
            expect( licence.name ).to eql("UK Open Government Licence (OGL)")            
        end
        
        it "should extract publisher details" do
            expect( @dataset.publishers.length ).to eql(1)
            publisher = @dataset.publishers.first
            expect( publisher.name ).to eql("Example Publisher")   
            expect( publisher.uri ).to eql("http://example.org/publisher")                                 
        end
           
        it "should extract keywords" do
            expect( @dataset.keywords.length ).to eql(2)
            expect( @dataset.keywords.first ).to eql("Examples")
            expect( @dataset.keywords.last ).to eql("DCAT")
        end
        
        it "should extract update frequency" do
            expect( @dataset.update_frequency).to eql("http://purl.org/linked-data/sdmx/2009/code#freq-W")
        end
    
        it "should extract distributions" do
            expect( @dataset.distributions.length).to eql(1)
            
            distribution = @dataset.distributions.first
            
            expect( distribution.title ).to eql("CSV download")
            expect( distribution.access_url).to eql("http://example.org/distribution.csv.zip")
        end
        
        it "should extract dates" do
            expect( @dataset.issued.to_s ).to eql("2010-10-25")
            expect( @dataset.modified.to_s ).to eql("2013-05-10")
        end
    end
    
    context "when parsing rights statements" do
        
        before(:each) do
            dcat_rdfa = File.read( File.join( File.dirname(File.realpath(__FILE__)) , "dcat-odrs-rdfa.html" ) )         
            FakeWeb.register_uri(:get, "http://example.org/rights", :body=>dcat_rdfa, :content_type=>"text/html")            
            @dataset = DataKitten::Dataset.new( access_url: "http://example.org/rights")        
        end        
        
        it "should extract licence URIs" do
            @dataset.rights.dataLicense = "http://reference.data.gov.uk/id/open-government-licence"
            @dataset.rights.contentLicense = "http://reference.data.gov.uk/id/open-government-licence"
        end
        
        it "should extract copyright information" do
            @dataset.rights.copyrightYear = "2013"
            @dataset.rights.databaseRightYear = "2013"
            @dataset.rights.copyrightHolder = "http://example.org"
            @dataset.rights.databaseRightHolder = "http://example.org"
            @dataset.rights.copyrightNotice = "Contains public sector information licensed under the Open Government Licence v1.0"
            @dataset.rights.copyrightStatement = "http://example.org/statement"
            @dataset.rights.databaseRightStatement = "http://example.org/statement"
            @dataset.rights.attributionText = "Example Department"
            @dataset.rights.attributionURL = "http://gov.example.org/dataset/finances"
        end
                
    end
end    
