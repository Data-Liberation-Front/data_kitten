module DataKitten

  module PublishingFormats
    
    module RDFXML
      
      include RDFa
            
      private
      
      def self.supported?(instance)
        doc = Nokogiri::HTML(open(instance.uri))
        
        rdf = doc.search('link[rel=alternate]').detect { |n| n[:type] == 'application/rdf+xml' }
                
        graph = RDF::Graph.load(rdf[:href], :format => :rdf)        
        
        query = RDF::Query.new({
          :dataset => {
            RDF.type  => RDF::Vocabulary.new("http://www.w3.org/ns/dcat#").Dataset
          }
        })
        
        query.execute(graph)[0][:dataset].to_s
      rescue
        false
      end
      
      public
      
      # The publishing format for the dataset.
      # @return [Symbol] +:rdfa+
      # @see Dataset#publishing_format
      def publishing_format
        :rdf
      end
      
      def uri
        doc = Nokogiri::HTML(open(access_url))
        rdf = doc.search('link[rel=alternate]').detect { |n| n[:type] == 'application/rdf+xml' }
        return rdf[:href]
      end
      
      private
      
      def graph
        @graph ||= RDF::Graph.load(uri, :format => :rdf)  
      end
      
    end
  end
end