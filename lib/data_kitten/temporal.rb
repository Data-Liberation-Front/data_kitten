module DataKitten
  # The temporal coverage of a {Dataset} or {Distribution}
  #
  class Temporal
    # @!attribute start
    #   @return [Date] the start date of the temporal coverage
    attr_accessor :start

    # @!attribute end
    #   @return [Date] the end date of the temporal coverage
    attr_accessor :end

    # Create a new Temporal object.
    #
    # @param options [Hash] A set of options with which to initialise the temporal coverage.
    # @option options [Date] :start the start date of the temporal coverage
    # @option options [Date] :end the end date of the temporal coverage
    def initialize(options)
      @start = options[:start]
      @end = options[:end]
    end
  end
end
