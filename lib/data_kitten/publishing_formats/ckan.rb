module DataKitten

  module PublishingFormats
    
    module CKAN
    
      private
    
      def self.supported?(instance)
        uri = URI(instance.uri)
        package = uri.path.split("/").last
        endpoint = "#{uri.scheme}://#{uri.host}/api/2/search/dataset"
        
        search = JSON.parse RestClient.get endpoint, {:params => {:q => package}}
        id = search["results"][0]
      rescue
        false
      end 
      
      public
      
      # The publishing format for the dataset.
      # @return [Symbol] +:ckan+
      # @see Dataset#publishing_format
      def publishing_format
        :ckan
      end
      
      # The human-readable title of the dataset.
      #
      # @see Dataset#data_title
      def data_title
        metadata["title"] rescue nil
      end
      
      # A brief description of the dataset
      #
      # @see Dataset#description
      def description
        metadata["notes"] rescue nil
      end
      
      # Keywords for the dataset
      #
      # @see Dataset#keywords
      def keywords
        keywords = []
        metadata["tags"].each do |tag|
          keywords << tag
        end
        return keywords
      rescue
        []
      end
      
      # A list of publishers.
      #
      # @see Dataset#publishers
      def publishers
        uri = URI(self.uri)
        group = JSON.parse RestClient.get "#{uri.scheme}://#{uri.host}/api/rest/group/#{metadata['groups'][0]}"
        
        [
          Agent.new(
                    :name => group["display_name"],
                    :homepage => group["extras"]["website-url"],
                    :mbox => metadata["extras"]["contact-email"]
                    )
        ]
      rescue
        []
      end
      
      # A list of licenses.
      #
      # @see Dataset#licenses
      def licenses
        [
          License.new(:id => metadata["license_id"], 
                      :uri => metadata["license_url"], 
                      :name => metadata["license_title"]
                      )
        ]
      rescue
        []
      end
      
      # A list of distributions, referred to as +resources+ by Datapackage.
      #
      # @see Dataset#distributions
      def distributions
        distributions = []
        metadata["resources"].each do |resource|
          distribution = {
            :title => resource["description"],
            :accessURL => resource["url"],
            :format => resource["format"]
          }
          distributions << Distribution.new(self, ckan_resource: distribution)
        end
        return distributions
      rescue
        nil
      end
  
      # How frequently the data is updated.
      #
      # @see Dataset#update_frequency
      def update_frequency
        metadata["extras"]["update_frequency"] rescue nil
      end
      
      # Date the dataset was released
      #
      # @see Dataset#issued
      def issued
        Date.parse metadata["metadata_created"] rescue nil
      end
      
      # Date the dataset was modified
      #
      # @see Dataset#modified
      def modified
        Date.parse metadata["metadata_modified"] rescue nil
      end
      
      private
                        
      def metadata
        uri = URI(self.uri)
        package = uri.path.split("/").last
        endpoint = "#{uri.scheme}://#{uri.host}/api/search/dataset"
        
        search = JSON.parse RestClient.get endpoint, {:params => {:q => package}}
        id = search["results"][0]
        JSON.parse RestClient.get "#{uri.scheme}://#{uri.host}/api/rest/package/#{id}"
      end
    
    end
  end
end