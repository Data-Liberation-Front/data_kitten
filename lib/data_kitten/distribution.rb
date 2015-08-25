module DataKitten

  # A specific available form of a dataset, such as a CSV file, an API, or an RSS feed.
  #
  # Based on {http://www.w3.org/TR/vocab-dcat/#class-distribution dcat:Distribution}, but
  # with useful aliases for other vocabularies.
  #
  class Distribution

    # @!attribute format
    #   @return [DistributionFormat] the file format of the distribution.
    attr_accessor :format

    # @!attribute access_url
    #   @return [String] a URL to access the distribution.
    attr_accessor :access_url

    # @!attribute download_url
    #   @return [String] a URL to the file of the distribution.
    attr_accessor :download_url
    alias_method :uri, :download_url

    # @!attribute path
    #   @return [String] the path of the distribution within the source, if appropriate
    attr_accessor :path

    # @!attribute title
    #   @return [String] a short title, unique within the dataset
    attr_accessor :title

    # @!attribute description
    #   @return [String] a textual description
    attr_accessor :description

    # @!attribute issued
    #   @return [Date] date created
    attr_accessor :issued

    # @!attribute modified
    #   @return [Date] date modified
    attr_accessor :modified

    # @!attribute byte_size
    #   @return [Integer] size of file in bytes
    attr_accessor :byte_size

    # @!attribute media_type
    #   @return [String] the IANA media type (MIME type) of the distribution
    attr_accessor :media_type

    # @!attribute schema
    #   @return [Hash] a hash representing the schema of the data within the distribution. Will
    #                  change to a more structured object later.
    attr_accessor :schema

    # @!attribute extension
    #   @return [String] the file extension of the distribution
    attr_accessor :extension

    # Create a new Distribution. Currently only loads from Datapackage +resource+ hashes.
    #
    # @param dataset [Dataset] the {Dataset} that this is a part of.
    # @param options [Hash] A set of options with which to initialise the distribution.
    # @option options [String] :datapackage_resource the +resource+ section of a Datapackage
    #                                                representation to load information from.
    def initialize(dataset, options)
      # Store dataset
      @dataset = dataset
      # Parse datapackage
      if r = options[:datapackage_resource]
        # Load basics
        @description = r['description']
        # Work out format
        @format = begin
          @extension = r['format']
          if @extension.nil?
            @extension = r['path'].is_a?(String) ? r['path'].split('.').last.upcase : nil
          end
          @extension ? DistributionFormat.new(self) : nil
        end
        # Get CSV dialect
        @dialect = r['dialect']
        # Extract schema
        @schema = r['schema']
        # Get path
        @path = r['path']
        @download_url = r['url']
        # Set title
        @title = @path || @uri
      elsif r = options[:dcat_resource]
        @title       = r[:title]
        @description = r[:title]
        @access_url  = r[:accessURL]
      elsif r = options[:ckan_resource]
        @title        = r[:title]
        @description  = r[:title]
        @issued       = r[:issued]
        @modified     = r[:modified]
        @access_url   = r[:accessURL]
        @download_url = r[:downloadURL]
        @byte_size    = r[:byteSize]
        @media_type   = r[:mediaType]
        @extension    = r[:format]
        # Load HTTP Response for further use
        @format = r[:format] ? DistributionFormat.new(self) : nil
      end
      # Set default CSV dialect
      @dialect ||= {
        "delimiter" => ","
      }

      @download = Fetcher.wrap(@download_url)
    end

    # A usable name for the distribution, unique within the {Dataset}.
    #
    # @return [String] a locally unique name
    def title
      @title
    end
    alias_method :name, :title

    # An array of column headers for the distribution. Loaded from the schema, or from the file directly if no
    # schema is present.
    #
    # @return [Array<String>] an array of column headers, as strings.
    def headers
      @headers ||= begin
        if @schema
          @schema['fields'].map{|x| x['id']}
        else
          data.headers
        end
      end
    end

    # Whether the file that the distribution represents actually exists
    #
    # @return [Boolean] whether the HTTP response returns a success code or not
    def exists?
      @download.exists?
    end

    # A CSV object representing the loaded data.
    #
    # @return [Array<Array<String>>] an array of arrays of strings, representing each row.
    def data
      @data ||= begin
        if @path
          datafile = @dataset.send(:load_file, @path)
        elsif @download.ok?
          datafile = @download.body
        end
        if datafile
          case format.extension
          when :csv
            CSV.parse(
              datafile,
              :headers => true,
              :col_sep => @dialect["delimiter"]
            )
          else
            nil
          end
        else
          nil
        end
      rescue
        nil
      end
    end

  end

end
