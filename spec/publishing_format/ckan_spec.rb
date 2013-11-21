require 'spec_helper'

describe DataKitten::PublishingFormats::CKAN do
  
  before(:all) do
      FakeWeb.clean_registry
      FakeWeb.allow_net_connect = false
  end
  
  context "With a CKAN 2 endpoint" do
  
    it "should detect CKAN Datasets" do
        FakeWeb.register_uri(:get, "http://example.org/ckan", :body=> "", :content_type=>"text/html")
        json = File.read( File.join( File.dirname(File.realpath(__FILE__)) , "..", "fixtures", "ckan-search-dataset.json" ) )
        FakeWeb.register_uri(:get, "http://example.org/api/2/search/dataset?q=ckan", :body => json, :content_type=>"application/json")          
        d = DataKitten::Dataset.new( access_url: "http://example.org/ckan")
        expect( d.publishing_format ).to eql(:ckan)        
        expect( d.supported? ).to eql(true)                    
    end
  
    context "when parsing CKAN" do
    
      before(:each) do
          search = File.read( File.join( File.dirname(File.realpath(__FILE__)) , "..", "fixtures", "ckan-search-dataset.json" ) )
          fetch = File.read( File.join( File.dirname(File.realpath(__FILE__)) , "..", "fixtures", "ckan-fetch-dataset.json" ) )
          FakeWeb.register_uri(:get, "http://example.org/api/2/search/dataset?q=ckan", :body => search, :content_type=>"application/json")          
          FakeWeb.register_uri(:get, "http://example.org/api/rest/package/47f7438a-506d-49c9-b565-7573f8df031e", :body => fetch, :content_type=>"application/json")          
          FakeWeb.register_uri(:get, "http://example.org/ckan", :body=> "", :content_type=>"text/html")
          @dataset = DataKitten::Dataset.new( access_url: "http://example.org/ckan")        
      end
    
      it "should get the title" do
        expect( @dataset.data_title ).to eql("Defence Infrastructure Organisation Disposals Database House of Commons Report")    
      end
    
      it "should get the description" do
        expect( @dataset.description ).to eql("MoD present and future disposal properties that are in the public domain that is provided for reference in the House of Commons library\r\n") 
      end
    
      it "should get the licence" do
        expect( @dataset.licenses.length ).to eql(1)
        licence = @dataset.licenses.first
        expect( licence.uri ).to eql("http://reference.data.gov.uk/id/open-government-licence")
        expect( licence.name ).to eql("UK Open Government Licence (OGL)")
        expect( licence.id ).to eql("uk-ogl")
      end

      it "should get the keywords" do
        expect( @dataset.keywords.length ).to eql(6)
        expect( @dataset.keywords[0] ).to eql("Defence")
        expect( @dataset.keywords[1] ).to eql("Government")
        expect( @dataset.keywords[2] ).to eql("Land and Property")
        expect( @dataset.keywords[3] ).to eql("Property")
        expect( @dataset.keywords[4] ).to eql("disposals")
        expect( @dataset.keywords[5] ).to eql("house of commons")
      end

      it "should get the publisher" do
        publisher = File.read( File.join( File.dirname(File.realpath(__FILE__)) , "..", "fixtures", "ckan-publisher.json" ) )
        FakeWeb.register_uri(:get, "http://example.org/api/rest/group/a3969e37-3ac3-42fe-8317-c8575a9f5317", :body=> publisher, :content_type=>"application/json")
        expect( @dataset.publishers.length ).to eql(1)
        publisher = @dataset.publishers.first
        expect( publisher.name ).to eql("Defence Infrastructure Organisation")   
        expect( publisher.uri ).to eql("http://www.example.com")
        expect( publisher.mbox ).to eql("foo@example.com")
      end
    
      it "should list the distributions" do
        expect( @dataset.distributions.length).to eql(1)
      
        expect( @dataset.distributions.first.access_url).to eql("https://www.gov.uk/government/publications/disposal-database-house-of-commons-report")
        expect( @dataset.distributions.first.description).to eql("Disposals Database House of Commons Report January 2013")
      end
    
      it "should get the update frequency" do
        expect( @dataset.update_frequency ).to eql("bi-monthly")
      end

      it "should get the issued date" do
        expect( @dataset.issued ).to eql(Date.parse("2012-10-05T13:51:55.812923"))
      end

      it "should get the modified date" do
        expect( @dataset.modified ).to eql(Date.parse("2013-11-16T02:37:42.408267"))
      end
    
      it "should get the temporal coverage" do
        temporal = @dataset.temporal
        expect( temporal.start ).to eql(Date.parse("2012-11-01"))
        expect( temporal.end ).to eql(Date.parse("2013-10-31"))
      end
    end
  end
  
  context "With a CKAN 3 endpoint" do
  
    it "should detect CKAN Datasets" do
        FakeWeb.register_uri(:get, "http://example.org/ckan", :body=> "", :content_type=>"text/html")
        json = File.read( File.join( File.dirname(File.realpath(__FILE__)) , "..", "fixtures", "ckan-3-search-dataset.json" ) )
        FakeWeb.register_uri(:get, "http://example.org/api/2/search/dataset?q=ckan", :body => "", :content_type=>"application/json")          
        FakeWeb.register_uri(:get, "http://example.org/api/3/action/package_search?q=ckan", :body => json, :content_type=>"application/json")          
        d = DataKitten::Dataset.new( access_url: "http://example.org/ckan")
        expect( d.publishing_format ).to eql(:ckan)        
        expect( d.supported? ).to eql(true)                    
    end
  
    context "when parsing CKAN" do
    
      before(:each) do
          search = File.read( File.join( File.dirname(File.realpath(__FILE__)) , "..", "fixtures", "ckan-3-search-dataset.json" ) )
          fetch = File.read( File.join( File.dirname(File.realpath(__FILE__)) , "..", "fixtures", "ckan-3-fetch-dataset.json" ) )
          FakeWeb.register_uri(:get, "http://example.org/api/2/search/dataset?q=ckan", :body => "", :content_type=>"application/json")          
          FakeWeb.register_uri(:get, "http://example.org/api/3/action/package_search?q=ckan", :body => search, :content_type=>"application/json")          
          FakeWeb.register_uri(:get, "http://example.org/api/rest/package/553b3049-2b8b-46a2-95e6-640d7986a8c1", :body => fetch, :content_type=>"application/json")          
          FakeWeb.register_uri(:get, "http://example.org/ckan", :body=> "", :content_type=>"text/html")
          @dataset = DataKitten::Dataset.new( access_url: "http://example.org/ckan")        
      end
    
      it "should get the title" do
        expect( @dataset.data_title ).to eql("National Public Toilet Map")    
      end
    
      it "should get the description" do
        expect( @dataset.description ).to eql("Here are some notes")
      end
    
      it "should get the licence" do
        expect( @dataset.licenses.length ).to eql(1)
        licence = @dataset.licenses.first
        expect( licence.uri ).to eql("http://creativecommons.org/licenses/by/3.0/au/")
        expect( licence.name ).to eql("Creative Commons Attribution 3.0 Australia")
        expect( licence.id ).to eql("cc-by")
      end

      it "should get the keywords" do
        expect( @dataset.keywords.length ).to eql(2)
        expect( @dataset.keywords[0] ).to eql("health")
        expect( @dataset.keywords[1] ).to eql("toilet")
      end

      it "should get the publisher" do
        publisher = File.read( File.join( File.dirname(File.realpath(__FILE__)) , "..", "fixtures", "ckan-3-publisher.json" ) )
        FakeWeb.register_uri(:get, "http://example.org/api/rest/group/2df7090e-2ebb-416e-8994-6de43d820d5c", :body=> publisher, :content_type=>"application/json")
        expect( @dataset.publishers.length ).to eql(1)
        publisher = @dataset.publishers.first
        expect( publisher.name ).to eql("Department of Health and Ageing")   
        expect( publisher.uri ).to eql("http://www.example.com")
        expect( publisher.mbox ).to eql("foo@example.com")
      end
    
      it "should list the distributions" do
        expect( @dataset.distributions.length).to eql(1)
      
        expect( @dataset.distributions.first.access_url).to eql("http://data.gov.au/storage/f/2013-11-14T05%3A41%3A12.200Z/toiletmapexport-131112-042111.zip")
        expect( @dataset.distributions.first.description).to eql("Toilet Map")
      end
      
      it "should get the issued date" do
        expect( @dataset.issued ).to eql(Date.parse("2013-05-12T08:42:38.802401"))
      end

      it "should get the modified date" do
        expect( @dataset.modified ).to eql(Date.parse("2013-11-14T05:44:59.497920"))
      end
    end
  end
  
end