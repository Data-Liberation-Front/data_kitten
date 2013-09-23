module DataKitten

  module PublishingFormats
    
    module LinkedData
      
      ACCEPT_HEADER = "text/turtle, application/n-triples, application/ld+json; q=1.0,application/rdf+xml; q=0.8, */*; q=0.5"
      
      include RDFa
            
      private
      
      #Find first resource with one of the specified RDF types
      def self.first_of_type(graph, classes)
          term = nil
          classes.each do |clazz|
              term = graph.first_subject(
                  RDF::Query::Pattern.new( nil, RDF.type, clazz ) )
               break if term
          end
          term
      end
      
      #Attempt to create an RDF graph for this object
      #
      #Supports content negotiation for various RDF serializations. Attempts "dataset autodiscovery" if it receives
      #an HTML response. This leaves the RDFa Publishing Format to just parse RDFa responses
      def self.create_graph(uri)
        
        resp = RestClient.get uri, 
            :accept=>ACCEPT_HEADER            
        return false if resp.code != 200

        if resp.headers[:content_type] =~ /text\/html/
            doc = Nokogiri::HTML( resp.body )
            link = doc.search('link[rel=alternate]').detect { |n| n[:type] == 'application/rdf+xml' }
            if link                
                resp = RestClient.get link["href"], 
                    :accept=>ACCEPT_HEADER            
                return false if resp.code != 200
            else
                return false
            end
        end
        
        reader = RDF::Reader.for( :content_type => resp.headers[:content_type] )
        return false unless reader

        graph = RDF::Graph.new()
        graph << reader.new( StringIO.new( resp.body ))
               
        return graph     
      rescue => e
        nil
      end

      #Can we create an RDF graph for this object containing the description of a dataset?
      def self.supported?(instance)
          graph = create_graph(instance.uri)
          return false unless graph
          return true if first_of_type(graph, 
              [RDF::Vocabulary.new("http://www.w3.org/ns/dcat#").Dataset, 
               RDF::Vocabulary.new("http://rdfs.org/ns/void#").Dataset])
          return false          
      end      
      
      public
      
      # The publishing format for the dataset.
      # @return [Symbol] +:rdfa+
      # @see Dataset#publishing_format
      def publishing_format
        :rdf
      end
            
      def uri
        access_url
      end
      
      private
      
      def dataset_uri
        access_url
      end
            
      def graph
        if !@graph
          @graph = LinkedData.create_graph(access_url)
        end
        @graph   
      end
      
    end
  end
end