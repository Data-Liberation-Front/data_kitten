require 'data_kitten/utils/guessable_lookup.rb'
require 'data_kitten/utils/ckan3_hash.rb'

module DataKitten

  module PublishingFormats

    module CKAN

      private

      def self.supported?(instance)
        uri = instance.uri
        base_uri = instance.base_uri
        *base, package = uri.path.split('/')
        if uri.path =~ %r{api/\d+/action/package_show/?$}
          result = JSON.parse(RestClient.get(uri.to_s))['result']

          instance.identifier = result['id']
          result['extras'] = CKAN3Hash.new(result['extras'], 'key', 'value')
          result['tags'] = CKAN3Hash.new(result['tags'], 'name', 'display_name').values
          instance.metadata = result
        elsif uri.path =~ %r{api/\d+/rest/dataset/}
          result = JSON.parse(RestClient.get(uri.to_s))
          instance.identifier = result['id']
          instance.metadata = result
        else
          # If the 2nd to last element in the path is 'dataset' then it's probably
          # the CKAN dataset view page, the last element will be the dataset id
          # or name
          if base.last == "dataset"
            instance.identifier = package
            # build a base URI ending with a /
            base_uri = uri.merge(base[0...-1].join('/') + '/')
          # If the package is a UUID - it's more than likely to be a CKAN ID
          elsif package.match(/[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}/)
            instance.identifier = package
          else
            results = begin
              RestClient.get base_uri.merge("api/3/action/package_show").to_s, {:params => {:id => package}}
            rescue RestClient::Exception
              RestClient.get base_uri.merge("api/2/rest/dataset/#{package}").to_s
            end

            result = JSON.parse results
            instance.identifier = result.fetch("result", result)["id"]
          end
          instance.metadata = JSON.parse RestClient.get base_uri.merge("api/rest/package/#{instance.identifier}").to_s
        end
        instance.metadata.extend(GuessableLookup)
        instance.source = instance.metadata
        return true
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

      # An identifier for the dataset
      #
      # @see Dataset#identifier
      def identifier
        metadata.lookup("name") || @identifier
      end

      # A web page which can be used to gain access to the dataset
      #
      # @see Dataset#landing_page
      def landing_page
        metadata.lookup("extras", "landing_page") ||
        metadata.lookup("url") ||
        metadata.lookup("ckan_url")
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
        org = fetch_organization
        result = if org
          [org]
        elsif group_id = metadata.lookup('groups', 0, 'id')
          [fetch_publisher(group_id)]
        else
          []
        end
        result.compact
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
            :accessURL => landing_page,
            :downloadURL => resource["url"],
            :format => resource["format"],
            :mediaType => resource["mimetype"] || resource["content_type"],
          }
          distribution[:issued] = Date.parse(resource["created"]) rescue nil
          distribution[:modified] = Date.parse(resource["last_modified"] || resource["revision_timestamp"]) rescue nil
          distribution[:byteSize] = Integer(resource["size"]) rescue nil
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
        Date.parse metadata.lookup("metadata_created") rescue nil
      end

      # Date the dataset was modified
      #
      # @see Dataset#modified
      def modified
        Date.parse metadata.lookup("metadata_modified") rescue nil
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

      # The language of the dataset
      #
      # @see Dataset#language
      def language
        metadata.lookup("language") ||
        metadata.lookup("metadata_language") ||
        metadata.lookup("extras", "metadata_language") ||
        metadata.lookup("extras", "language", 0) ||
        metadata.lookup("extras", "language")
      end

      # The main category of the dataset
      #
      # @see Dataset#theme
      def theme
        metadata.lookup("extras", "theme", 0) ||
        metadata.lookup("extras", "theme-primary") ||
        metadata.lookup("groups", 0, "name") ||
        metadata.lookup("groups", 0)
      end

      # Spatial coverage of the dataset
      #
      # @see Dataset#spatial
      def spatial
        extract_spatial || extract_bbox
      end

      private

      def without_empty_values(h)
        h.reject { |k, v| v.nil? || v.empty? }
      end

      def select_extras(group, key)
        extra = group["extras"][key] rescue ""
        if extra == ""
          extra = group['result']['extras'].select {|e| e["key"] == key }.first['value'] rescue ""
        end
        extra
      end

      def extract_spatial
        geometry = JSON.parse metadata.lookup("extras", "spatial")
        return geometry if !geometry["type"].nil?
      rescue
        nil
      end
      
      def extract_bbox
        west = Float(metadata.lookup("extras", "bbox-west-long"))
        east = Float(metadata.lookup("extras", "bbox-east-long"))
        north = Float(metadata.lookup("extras", "bbox-north-lat"))
        south = Float(metadata.lookup("extras", "bbox-south-lat"))

        { "type" => "Polygon", "coordinates" => [
          [
            [west, north],
            [east, north],
            [east, south],
            [west, south],
            [west, north]
          ]
        ] }
      rescue
        nil
      end

      def fetch_organization
        if org = metadata['organization']
          begin
            uri = base_uri.merge("api/3/action/organization_show")
            result = RestClient.get(uri.to_s, params: {id: org['id']})
            org_data = JSON.parse(result)['result']
            extras = CKAN3Hash.new(without_empty_values(org_data['extras']), "key", "value")
          rescue
            uri = base_uri.merge("api/rest/group/#{org['id']}")
            result = RestClient.get(uri.to_s)
            org_data = JSON.parse(result)
            extras = without_empty_values(org_data['extras'])
          end
          Agent.new(
            :name => org_data['title'],
            :mbox => (org_data['contact-email'] || extras['contact-email']),
            :homepage => extras['website-url'] || base_uri.to_s
          )
        end
      rescue
        nil
      end

      def fetch_publisher(id)
        uri = parsed_uri
        [
          "api/3/action/organization_show?id=#{id}",
          "api/3/action/group_show?id=#{id}",
          "api/rest/group/#{id}"
        ].each do |uri|
          begin
            @group = JSON.parse RestClient.get base_uri.merge(uri).to_s
            break
          rescue
            # FakeWeb raises FakeWeb::NetConnectNotAllowedError, whereas 
            # RestClient raises RestClient::ResourceNotFound in the "real world".
            nil
          end
        end

        if @group
          Agent.new(:name => @group["display_name"] || @group["result"]["title"],
                    :homepage => select_extras(@group, "website-url"),
                    :mbox => select_extras(@group, "contact-email"))
        end
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
