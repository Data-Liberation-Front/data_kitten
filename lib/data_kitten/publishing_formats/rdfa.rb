module DataKitten

  module PublishingFormats
    
    module RDFa
      
      private
      
      def self.supported?(instance)
        graph = RDF::Graph.load(instance.uri, :format => :rdfa)
        
        query = RDF::Query.new({
          :dataset => {
            RDF.type  => dcat.Dataset
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
        :rdfa
      end
      
      # A list of maintainers.
      #
      # @see Dataset#maintainers
      def maintainers
        []
      end
      
      # A list of publishers.
      #
      # @see Dataset#publishers
      def publishers
        publishers = []
        uris = metadata[dataset_uri][dct.publisher.to_s]
        uris.each do |uri|
          p = metadata[uri]
          publishers << Agent.new(:name => p[RDF::FOAF.name.to_s], :homepage => p[RDF::FOAF.homepage.to_s], :mbox => p[RDF::FOAF.mbox.to_s])
        end
        return publishers
      end
      
      # The rights statment for the data
      #
      # @see Dataset#rights
      def rights
        uri = metadata[dataset_uri][dct.rights.to_s][0]
        rights = metadata[uri]
        rights = Rights.new(:uri => uri, 
                            :dataLicense => rights[odil.dataLicense.to_s][0], 
                            :contentLicense => rights[odil.contentLicense.to_s][0], 
                            :copyrightNotice => rights[odil.copyrightNotice.to_s][0], 
                            :attributionURL => rights[odil.attributionURL.to_s][0],
                            :attributionText => rights[odil.attributionText.to_s][0]
                            )
        return rights
      end
      
      # A list of licenses.
      #
      # @see Dataset#licenses
      def licenses
        licenses = []
        uris = metadata[dataset_uri][dct.license.to_s]
        uris.each do |uri|
          l = metadata[uri]
          licenses << License.new(:uri => uri, :name => l[dct.title.to_s])
        end
        return licenses
      end
      
      # A list of contributors.
      #
      # @see Dataset#contributors
      def contributors
        []
      end
      
      # A list of distributions, referred to as +resources+ by Datapackage.
      #
      # @see Dataset#distributions
      def distributions
        distributions = []
        uris = metadata[dataset_uri][dcat.distribution.to_s]
        uris.each do |uri|
          d = metadata[uri]
          distribution = {
            :title => d[dct.title.to_s][0],
            :accessURL => d[dcat.accessURL.to_s][0],
            :issued => d[dct.issued.to_s][0]
          }
          distributions << Distribution.new(self, dcat_resource: distribution)
        end
        return distributions
      end
      
      # The human-readable title of the dataset.
      #
      # @see Dataset#data_title
      def data_title
        metadata[dataset_uri][dct.title.to_s][0]
      end
      
      # A brief description of the dataset
      #
      # @see Dataset#description
      def description
        metadata[dataset_uri][dct.description.to_s][0]
      end
      
      # Keywords for the dataset
      #
      # @see Dataset#keywords
      def keywords
        keywords = []
        metadata[dataset_uri][dcat.keyword.to_s].each do |k|
          keywords << k
        end
      end
      
      # Where the data is sourced from
      #
      # @see Dataset#sources
      def sources
        []
      end
      
      # How frequently the data is updated.
      #
      # @see Dataset#update_frequency
      def update_frequency
        metadata[dataset_uri][dct.accrualPeriodicity.to_s][0]
      end
      
      private
      
      def graph
        @graph ||= RDF::Graph.load(uri, :format => :rdfa)  
      end
                        
      def metadata        
        @metadata ||= {}
        
        # This is UGLY, and exists solely to make getting data out of the graph easier. We will probably change this later       
        graph.triples.each do |triple|
          @metadata[triple[0].to_s] ||= {}
          @metadata[triple[0].to_s][triple[1].to_s] ||= []
          @metadata[triple[0].to_s][triple[1].to_s] << triple[2].to_s unless @metadata[triple[0].to_s][triple[1].to_s].include? triple[2].to_s
        end
        
        return @metadata
      end
      
      def dataset_uri
        query = RDF::Query.new({
          :dataset => {
            RDF.type  => dcat.Dataset
          }
        })
        
        query.execute(graph)[0][:dataset].to_s
      end
      
      def dcat
        RDF::Vocabulary.new("http://www.w3.org/ns/dcat#")
      end
      
      def dct
        RDF::Vocabulary.new("http://purl.org/dc/terms/")
      end
      
      def odil
        RDF::Vocabulary.new("http://theodi.github.io/open-data-licensing/schema#")
      end
            
    end
    
  end
  
end