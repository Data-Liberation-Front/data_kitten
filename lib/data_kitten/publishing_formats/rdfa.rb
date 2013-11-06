module DataKitten

  module PublishingFormats
    
    module RDFa
      
      private
      
      def self.supported?(instance)
        graph = RDF::Graph.load(instance.uri, :format => :rdfa)
        
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
        uris = metadata[dataset_uri][RDF::DC.publisher.to_s]
        uris.each do |publisher_uri|
          publishers << Agent.new(:name => first_value( publisher_uri, RDF::FOAF.name ), 
                                  :homepage => first_value( publisher_uri, RDF::FOAF.homepage ), 
                                  :mbox => first_value( publisher_uri, RDF::FOAF.mbox ))
        end
        return publishers
      rescue
        []    
      end
      
      # The rights statment for the data
      #
      # @see Dataset#rights
      def rights
        rights_uri = metadata[dataset_uri][RDF::DC.rights.to_s][0]
        if !metadata[rights_uri]
            return Rights.new(:uri => rights_uri)
        else
          return Rights.new(:uri => uri, 
                              :dataLicense => first_value( rights_uri, odrs.dataLicense ), 
                              :contentLicense => first_value( rights_uri, odrs.contentLicense ), 
                              :copyrightNotice => first_value( rights_uri, odrs.copyrightNotice ), 
                              :attributionURL => first_value( rights_uri, odrs.attributionURL ),
                              :attributionText => first_value( rights_uri, odrs.attributionText ),
                              :copyrightHolder => first_value( rights_uri, odrs.copyrightHolder ),
                              :databaseRightHolder => first_value( rights_uri, odrs.databaseRightHolder ),
                              :copyrightYear => first_value( rights_uri, odrs.copyrightYear ),
                              :databaseRightYear => first_value( rights_uri, odrs.databaseRightYear ),
                              :copyrightStatement => first_value( rights_uri, odrs.copyrightStatement ),
                              :databaseRightStatement => first_value( rights_uri, odrs.databaseRightStatement )
                              )
        end
      rescue => e
        puts e
        puts e.backtrace
        nil
      end
      
      # A list of licenses.
      #
      # @see Dataset#licenses
      def licenses
        licenses = []
        uris = metadata[dataset_uri][RDF::DC.license.to_s]
        if uris.nil?
          []
        else
          uris.each do |license_uri|
            licenses << License.new(:uri => license_uri, :name => first_value( license_uri, RDF::DC.title ))
          end
          return licenses
        end
      rescue => e
        []
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
        uris.each do |distribution_uri|
          distribution = {
            :title => first_value( distribution_uri, RDF::DC.title ),
            :accessURL => first_value( distribution_uri, dcat.accessURL )
          }
          distributions << Distribution.new(self, dcat_resource: distribution)
        end
        return distributions
      rescue
        []
      end
      
      # The human-readable title of the dataset.
      #
      # @see Dataset#data_title
      def data_title
        metadata[dataset_uri][dct.title.to_s][0] rescue nil
      end
      
      # A brief description of the dataset
      #
      # @see Dataset#description
      def description
        metadata[dataset_uri][dct.description.to_s][0] rescue nil
      end
      
      # Keywords for the dataset
      #
      # @see Dataset#keywords
      def keywords
        keywords = []
        metadata[dataset_uri][dcat.keyword.to_s].each do |k|
          keywords << k
        end
      rescue
        []
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
        first_value( dataset_uri, dcat.accrualPeriodicity )
      end
      
      def issued
        date = first_value(dataset_uri, RDF::DC.issued) || 
               first_value(dataset_uri, RDF::DC.created)
        if date
            return Date.parse( date )
        end
        return nil
      end
    
      def modified
        date = first_value(dataset_uri, RDF::DC.modified)
        if date
            return Date.parse( date )
        end
        return nil
      end
      
      private
            
      def graph
        @graph ||= RDF::Graph.load(uri, :format => :rdfa)  
      end
              
      def first_value(resource, property, default=nil)
          if metadata[resource] && metadata[resource][property.to_s]
              return metadata[resource][property.to_s][0]
          end
          return default
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
      
      def odrs
        RDF::Vocabulary.new("http://schema.theodi.org/odrs#")
      end
      
      def void
        RDF::Vocabulary.new("http://rdfs.org/ns/void#")
      end
            
    end
    
  end
  
end
