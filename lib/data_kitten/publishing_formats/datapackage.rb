module DataKitten
  module PublishingFormats
    # Datapackage metadata format module. Automatically mixed into {Dataset} for datasets that include a +datapackage.json+.
    #
    # @see Dataset
    #
    module Datapackage
      def self.supported?(instance)
        if instance.send(:origin) == :git
          metadata = instance.send(:load_file, "datapackage.json")
          datapackage = DataPackage::Package.new(JSON.parse(metadata))

        else
          datapackage = DataPackage::Package.new(instance.url)
        end
        !datapackage.datapackage_version.nil?
      rescue => _e
        false
      end

      # The publishing format for the dataset.
      # @return [Symbol] +:datapackage+
      # @see Dataset#publishing_format
      def publishing_format
        :datapackage
      end

      # A list of maintainers.
      #
      # @see Dataset#maintainers
      def maintainers
        package.maintainers.map do |x|
          Agent.new(name: x["name"], uri: x["web"], email: x["email"])
        end
      end

      # A list of publishers.
      #
      # @see Dataset#publishers
      def publishers
        package.publisher.map do |x|
          Agent.new(name: x["name"], uri: x["web"], email: x["email"])
        end
      end

      # A list of licenses.
      #
      # @see Dataset#licenses
      def licenses
        package.licenses.map do |x|
          License.new(id: x["id"], uri: x["url"], name: x["name"])
        end
      end

      def rights
        if package.property("rights")
          Rights.new(package.property("rights", []).each_with_object({}) { |(k, v), h| h[k.to_sym] = v })
        end
      end

      # A list of contributors.
      #
      # @see Dataset#contributors
      def contributors
        package.contributors.map do |x|
          Agent.new(name: x["name"], uri: x["web"], email: x["email"])
        end
      end

      # A list of distributions, referred to as +resources+ by Datapackage.
      #
      # @see Dataset#distributions
      def distributions
        package.resources.map { |resource| Distribution.new(self, datapackage_resource: resource) }
      end

      # The human-readable title of the dataset.
      #
      # @see Dataset#data_title
      def data_title
        package.title || package.name
      end

      # A brief description of the dataset
      #
      # @see Dataset#description
      def description
        package.description
      end

      # Keywords for the dataset
      #
      # @see Dataset#keywords
      def keywords
        package.keywords
      end

      # Where the data is sourced from
      #
      # @see Dataset#sources
      def sources
        package.sources.map do |x|
          Source.new(label: x["name"], resource: x["web"])
        end
      end

      # Date the dataset was modified
      def modified
        package.last_modified
      end

      # A history of changes to the Dataset.
      #
      # If {Dataset#source} is +:git+, this is the git changelog for the actual distribution files, rather
      # then the full unfiltered log.
      #
      # @return [Array] An array of changes. Exact format depends on the source.
      #
      # @see Dataset#change_history
      def change_history
        @change_history ||= begin
          if origin == :git
            # Get a log for each file in the local repo
            logs = distributions.map { |file|
              if file.path
                log = repository.log.path(file.path)
                # Convert to list of commits
                log.map { |commit| commit }
              else
                []
              end
            }
            # combine all logs, make unique, and re-sort in date order
            logs.flatten.uniq.sort_by { |x| x.committer.date }.reverse
          else
            []
          end
        end
      end

      private

      def package
        unless @datapackage
          if origin == :git
            metadata = load_file("datapackage.json")
            @datapackage = DataPackage::Package.new(JSON.parse(metadata))
          else
            @datapackage = DataPackage::Package.new(url)
          end
        end
        @datapackage
      end
    end
  end
end
