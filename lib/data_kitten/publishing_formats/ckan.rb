require 'data_kitten/utils/guessable_lookup.rb'

module DataKitten

  module PublishingFormats

    module CKAN

      @@metadata = nil

      private

      def self.supported?(instance)
        uri = instance.uri
        package = uri.path.split("/").last
        # If the package is a UUID - it's more than likely to be a CKAN ID
        if package.match(/[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}/)
          @@id = package
        else

          results = RestClient.get "#{uri.scheme}://#{uri.host}/api/3/action/package_show", {:params => {:id => package}} rescue ""

          if results == ""
            results = RestClient.get "#{uri.scheme}://#{uri.host}/api/2/rest/dataset/#{package}"
          end

          result = JSON.parse results
          @@id = result["result"]["id"] rescue result["id"]
        end
        @@metadata = JSON.parse RestClient.get "#{uri.scheme}://#{uri.host}/api/rest/package/#{@@id}"
        @@metadata.extend(GuessableLookup)
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
        metadata.lookup("title")
      end

      # A brief description of the dataset
      #
      # @see Dataset#description
      def description
        metadata.lookup("notes") || metadata.lookup("description")
      rescue 
        nil
      end
      
      def identifier
        metadata.lookup("name")
      end
      
      def landingPage
        metadata.lookup("extras", "landingPage")
        # TODO: somehow get original package URL
      end

      # Keywords for the dataset
      #
      # @see Dataset#keywords
      def keywords
        keywords = []
        metadata.lookup("tags").each do |tag|
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
        id = metadata.lookup('organization', 'id') || metadata.lookup('groups', 0)
        fetch_publisher(id)
      rescue
        []
      end

      def maintainers
        extract_agent('maintainer', 'maintainer_email')
      end

      def contributors
        extract_agent('author', 'author_email')
      end

      # A list of licenses.
      #
      # @see Dataset#licenses
      def licenses
        id = metadata.lookup("license_id")
        uri = metadata.lookup("license_url") || metadata.lookup("extras", "licence_url")
        name = metadata.lookup("license_title") || metadata.lookup("extras", "licence_url_title")
        if [id, uri, name].any?
          [License.new(:id => id, :uri => uri, :name => name)]
        else
          []
        end
      end

      # A list of distributions, referred to as +resources+ by Datapackage.
      #
      # @see Dataset#distributions
      def distributions
        distributions = []
        metadata.lookup("resources").each do |resource|
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
        metadata.lookup("extras", "update_frequency") ||
        metadata.lookup("extras", "frequency-of-update") ||
        metadata.lookup("extras", "accrual_periodicity")
      rescue
        nil
      end

      # Date the dataset was released
      #
      # @see Dataset#issued
      def issued
        Date.parse metadata.lookup("metadata_created")
      end

      # Date the dataset was modified
      #
      # @see Dataset#modified
      def modified
        Date.parse metadata.lookup("metadata_modified")
      end

      # The temporal coverage of the dataset
      #
      # @see Dataset#temporal
      def temporal
        from = metadata.lookup("extras", "temporal_coverage-from") ||
               metadata.lookup("extras", "temporal-extent-begin")
        to = metadata.lookup("extras", "temporal_coverage-to") ||
             metadata.lookup("extras", "temporal-extent-end")
        start_date = Date.parse from rescue nil
        end_date = Date.parse to rescue nil
        Temporal.new(:start => start_date, :end => end_date)
      end

      private

      def metadata
        @@metadata
      end

      def select_extras(group, key)
        extra = group["extras"][key] rescue ""
        if extra == ""
          extra = group['result']['extras'].select {|e| e["key"] == key }.first['value'] rescue ""
        end
        extra
      end

      def fetch_publisher(id)
        uri = parsed_uri
        [
          "#{uri.scheme}://#{uri.host}/api/rest/group/#{id}",
          "#{uri.scheme}://#{uri.host}/api/3/action/group_show?id=#{id}",
          "#{uri.scheme}://#{uri.host}/api/3/action/organization_show?id=#{id}"
        ].each do |uri|
          begin
            @group = JSON.parse RestClient.get uri
            break
          rescue RestClient::ResourceNotFound
            nil
          end
        end

        [
          Agent.new(
                    :name => @group["display_name"] || @group["result"]["title"],
                    :homepage => select_extras(@group, "website-url"),
                    :mbox => select_extras(@group, "contact-email")
                    )
        ]
      end

      def parsed_uri
        URI(self.uri)
      end

      def extract_agent(name_field, email_field)
        name = metadata.lookup(name_field)
        email = metadata.lookup(email_field)
        if [name, email].any?
          [Agent.new(name: name, mbox: email)]
        else
          []
        end
      end

    end
  end
end
