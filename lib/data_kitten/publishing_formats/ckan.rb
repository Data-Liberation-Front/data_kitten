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
        id = metadata['organization']['id'] || metadata['groups'][0]
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
        extras = metadata["extras"] || {}
        id = metadata["license_id"]
        uri = metadata["license_url"] || extras["licence_url"]
        name = metadata["license_title"] || extras["licence_url_title"]
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
        metadata["extras"]["update_frequency"] || metadata["extras"]["frequency-of-update"] rescue nil
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

      # The temporal coverage of the dataset
      #
      # @see Dataset#temporal
      def temporal
        start_date = Date.parse metadata["extras"]["temporal_coverage-from"] rescue nil
        end_date = Date.parse metadata["extras"]["temporal_coverage-to"] rescue nil
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
        name = metadata[name_field]
        email = metadata[email_field]
        if [name, email].any?
          [Agent.new(name: name, mbox: email)]
        else
          []
        end
      end

    end
  end
end
