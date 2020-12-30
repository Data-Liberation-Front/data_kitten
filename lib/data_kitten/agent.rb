module DataKitten
  # A person or organisation.
  #
  # Naming is based on {http://xmlns.com/foaf/spec/#term_Agent foaf:Agent}, but with useful aliases for other vocabularies.
  class Agent
    # Create a new Agent
    #
    # @param [Hash] options the details of the Agent.
    # @option options [String] :name The Agent's name
    # @option options [String] :homepage The homepage URL for the Agent
    # @option options [String] :mbox Email address for the Agent
    #
    def initialize(options)
      @name = options[:name]
      @homepage = options[:homepage]
      @mbox = options[:mbox]
    end

    # @!attribute name
    #   @return [String] the name of the Agent
    attr_accessor :name

    # @!attribute homepage
    #   @return [String] the homepage URL of the Agent
    attr_accessor :homepage
    alias url homepage
    alias uri homepage

    # @!attribute mbox
    #   @return [String] the email address of the Agent
    attr_accessor :mbox
    alias email mbox

    def ==(agent)
      agent.is_a?(Agent) && ([name, homepage, mbox] == [agent.name, agent.homepage, agent.mbox])
    end
  end
end
