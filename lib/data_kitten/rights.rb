module DataKitten

  # A rights statement for a {Dataset} or {Distribution}
  #
  class Rights

    # @!attribute uri
    #   @return [String] the URI for the rights statement
    attr_accessor :uri
    
    # @!attribute dataLicense
    #   @return [String] the license for the data in the dataset.
    attr_accessor :dataLicense
    
    # @!attribute contentLicense
    #   @return [String] the license for the content in the dataset.
    attr_accessor :contentLicense
    
    # @!attribute copyrightNotice
    #   @return [String] the copyright notice for the dataset.
    attr_accessor :copyrightNotice
    
    # @!attribute attributionURL
    #   @return [String] the attribution URL for the dataset.
    attr_accessor :attributionURL

    # @!attribute attributionText
    #   @return [String] the attribution text for the dataset.
    attr_accessor :attributionText

    # @!attribute copyrightHolder
    #   @return [String] the URI of the organization that holds copyright for this dataset
    attr_accessor :copyrightHolder
    
    # @!attribute databaseRightHolder
    #   @return [String] the URI of the organization that owns the database rights for this dataset
    attr_accessor :databaseRightHolder
          
    # @!attribute copyrightYear
    #   @return [String] the year in which copyright is claimed
    attr_accessor :copyrightYear   
   
    # @!attribute databaseRightYear
    #   @return [String] the year in which copyright is claimed
    attr_accessor :databaseRightYear      
    
    # @!attribute copyrightStatement
    #   @return [String] the URL of a copyright statement for the dataset
    attr_accessor :copyrightStatement   
    
    # @!attribute databaseRightStatement
    #   @return [String] the URL of a database right statement for the dataset
    attr_accessor :databaseRightStatement       
    
    # Create a new Rights object.
    #
    # @param options [Hash] A set of options with which to initialise the license.
    # @option options [String] :dataLicense the license for the data in the dataset
    # @option options [String] :contentLicense the license for the content in the dataset
    # @option options [String] :copyrightNotice the copyright notice for the dataset
    # @option options [String] :attributionURL the attribution URL for the dataset
    # @option options [String] :attributionText attribution name for the dataset
    def initialize(options)
      @uri = options[:uri]
      @dataLicense = options[:dataLicense]
      @contentLicense = options[:contentLicense]
      @copyrightNotice = options[:copyrightNotice]
      @attributionURL = options[:attributionURL]
      @attributionText = options[:attributionText]
      @copyrightHolder = options[:copyrightHolder]
      @databaseRightHolder = options[:databaseRightHolder]
      @copyrightYear = options[:copyrightYear]
      @databaseRightYear = options[:databaseRightYear]
      @copyrightStatement = options[:copyrightStatement]
      @databaseRightStatement = options[:databaseRightStatement]
    end

  end  

end