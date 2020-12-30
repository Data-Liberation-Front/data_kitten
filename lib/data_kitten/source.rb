module DataKitten
  # Where the data has been sourced from
  # Follows the pattern of {http://purl.org/dc/terms/source} with a {http://www.w3.org/2000/01/rdf-schema#label} and a {http://www.w3.org/1999/02/22-rdf-syntax-ns#resource}, and with useful aliases for other vocabularies

  class Source
    # Create a new Source
    #
    # @param [Hash] options the details of the Source.
    # @option options [String] :label The name of the Source
    # @option options [String] :resource The URI of the Source
    #
    def initialize(options)
      @label = options[:label]
      @resource = options[:resource]
    end

    # @!attribute label
    #   @return [String] the name of the Source
    attr_accessor :label
    alias name label

    # @!attribute label
    #   @return [String] the URI of the Source
    attr_accessor :resource
    alias web resource
  end
end
