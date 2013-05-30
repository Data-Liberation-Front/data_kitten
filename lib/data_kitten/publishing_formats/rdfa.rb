module DataKitten

  module PublishingFormats
    
    module RDFa
      
      private
      
      def self.supported?(instance)
        @graph = RDF::Graph.load(instance.uri, :format => :rdfa)
      rescue
        false
      end
      
      public
      
      def publishing_format
        :rdfa
      end
            
    end
    
  end
  
end