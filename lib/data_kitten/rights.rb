module DataKitten
  # A rights statement for a {Dataset} or {Distribution}
  #
  class Rights
    # @!attribute uri
    #   @return [String] the URI for the rights statement
    attr_accessor :uri

    # @!attribute data_license
    #   @return [String] the license for the data in the dataset.
    attr_accessor :data_license
    alias dataLicense data_license

    # @!attribute content_license
    #   @return [String] the license for the content in the dataset.
    attr_accessor :content_license
    alias contentLicense content_license

    # @!attribute copyrightNotice
    #   @return [String] the copyright notice for the dataset.
    attr_accessor :copyright_notice
    alias copyrightNotice copyright_notice

    # @!attribute attribution_url
    #   @return [String] the attribution URL for the dataset.
    attr_accessor :attribution_url
    alias attributionURL attribution_url

    # @!attribute attribution_text
    #   @return [String] the attribution text for the dataset.
    attr_accessor :attribution_text
    alias attributionText attribution_text

    # @!attribute copyright_holder
    #   @return [String] the URI of the organization that holds copyright for this dataset
    attr_accessor :copyright_holder
    alias copyrightHolder copyright_holder

    # @!attribute database_right_holder
    #   @return [String] the URI of the organization that owns the database rights for this dataset
    attr_accessor :database_right_holder
    alias databaseRightHolder database_right_holder

    # @!attribute copyright_year
    #   @return [String] the year in which copyright is claimed
    attr_accessor :copyright_year
    alias copyrightYear copyright_year

    # @!attribute database_right_year
    #   @return [String] the year in which copyright is claimed
    attr_accessor :database_right_year
    alias databaseRightYear database_right_year

    # @!attribute copyright_statement
    #   @return [String] the URL of a copyright statement for the dataset
    attr_accessor :copyright_statement
    alias copyrightStatement copyright_statement

    # @!attribute database_right_statement
    #   @return [String] the URL of a database right statement for the dataset
    attr_accessor :database_right_statement
    alias databaseRightStatement database_right_statement

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
      @data_license = options[:dataLicense]
      @content_license = options[:contentLicense]
      @copyright_notice = options[:copyrightNotice]
      @attribution_url = options[:attributionURL]
      @attribution_text = options[:attributionText]
      @copyright_holder = options[:copyrightHolder]
      @database_right_holder = options[:databaseRightHolder]
      @copyright_year = options[:copyrightYear]
      @database_right_year = options[:databaseRightYear]
      @copyright_statement = options[:copyrightStatement]
      @database_right_statement = options[:databaseRightStatement]
    end
  end
end
