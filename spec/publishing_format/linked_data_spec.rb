require 'spec_helper'

describe DataKitten::PublishingFormats::LinkedData do

    before(:each) do
        FakeWeb.clean_registry
    end
    
    context "when detecting format" do
    
        it "should ignore errors" do       
            FakeWeb.register_uri(:get, "http://example.org/not-found", :status => ["404", "Not Found"])            
            d = DataKitten::Dataset.new("http://example.org/not-found")
            expect( d.supported? ).to eql(false)        
        end
        
        it "should support dataset autodiscovery" do       
            rdf_body=<<-EOL 
                <rdf:Description 
                    rdf:about="http://example.org/doc/dataset" 
                    xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
                    rdf:type="http://www.w3.org/ns/dcat#Dataset">
                </rdf:Description>       
            EOL
    
            html_body=<<-EOL
                <html>
                    <head>
                        <link rel="alternate" type="application/rdf+xml" 
                            href="http://example.org/doc/dataset.rdf"
                    </head>
                </html>        
            EOL
            FakeWeb.register_uri(:get, "http://example.org/doc/dataset", :body=>html_body, :content_type=>"text/html")            
            FakeWeb.register_uri(:get, "http://example.org/doc/dataset.rdf", :body=>rdf_body, :content_type=>"application/rdf+xml")
            
            d = DataKitten::Dataset.new("http://example.org/doc/dataset")
            expect( d.publishing_format ).to eql(:rdf)        
        end
        
        it "should support turtle" do
            body=<<-EOL 
              <http://example.org/doc/dataset> a <http://www.w3.org/ns/dcat#Dataset>.
            EOL
    
            FakeWeb.register_uri(:get, "http://example.org/doc/dataset", :body=>body, :content_type=>"text/turtle") 
            d = DataKitten::Dataset.new("http://example.org/doc/dataset")
            expect( d.publishing_format ).to eql(:rdf)                 
        end

        it "should fallback to using suffix of URI" do
            body=<<-EOL 
              <http://example.org/doc/dataset> <http://www.w3.org/1999/02/22-rdf-syntax-ns#type> <http://www.w3.org/ns/dcat#Dataset>.
            EOL
    
            FakeWeb.register_uri(:get, "http://example.org/doc/dataset.ttl", :body=>body, :content_type=>"text/plain") 
            d = DataKitten::Dataset.new("http://example.org/doc/dataset.ttl")
            expect( d.publishing_format ).to eql(:rdf)                 
        end        
                
        it "should support VoiD datasets" do
            body=<<-EOL 
              <http://example.org/doc/dataset> a <http://rdfs.org/ns/void#Dataset>.
            EOL
    
            FakeWeb.register_uri(:get, "http://example.org/doc/dataset", :body=>body, :content_type=>"text/turtle") 
            d = DataKitten::Dataset.new("http://example.org/doc/dataset")
            expect( d.publishing_format ).to eql(:rdf)                 
        end    
        
        it "should ignore unknown types" do
            body=<<-EOL 
              <http://example.org/doc/dataset> a <http://example.org/doc/Dataset>.
            EOL
    
            FakeWeb.register_uri(:get, "http://example.org/doc/dataset", :body=>body, :content_type=>"text/turtle") 
            d = DataKitten::Dataset.new("http://example.org/doc/dataset")
            expect( d.publishing_format ).to eql(nil)                 
        end      
    end
    
    context "when interpreting RDF" do
        
        it "should find the title" do
            body=<<-EOL 
              @prefix dct: <http://purl.org/dc/terms/> .
              <http://example.org/doc/dataset> a <http://www.w3.org/ns/dcat#Dataset>.
              <http://example.org/doc/dataset> dct:title "Dataset Title".
            EOL
    
            FakeWeb.register_uri(:get, "http://example.org/doc/dataset", :body=>body, :content_type=>"text/turtle") 
            d = DataKitten::Dataset.new("http://example.org/doc/dataset")
            expect( d.data_title ).to eql("Dataset Title")                 
        end        
        
    end
    
end
