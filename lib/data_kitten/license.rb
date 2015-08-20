module DataKitten

  # A license for a {Dataset} or {Distribution}
  #
  class License
    
    LICENSES = {
      /opendatacommons.org.*\/by(\/|$)/ => "odc-by",
      /opendatacommons.org.*\/odbl(\/|$)/ => "odc-odbl",
      /opendatacommons.org.*\/pddl(\/|$)/ => "odc-pddl",
      /opendefinition.org.*\/odc-by(\/|$)/ => "odc-by",
      /opendefinition.org.*\/odc-pddl(\/|$)/ => "odc-pddl",
      /opendefinition.org.*\/cc-zero(\/|$)/ => "cc-zero",
      /opendefinition.org.*\/cc-by(\/|$)/ => "cc-by",
      /opendefinition.org.*\/cc-by-sa(\/|$)/ => "cc-by-sa",
      /opendefinition.org.*\/gfdl(\/|$)/ => "gfdl",
      /creativecommons.org.*\/zero(\/|$)/ => "cc-zero",
      /creativecommons.org.*\/by-sa(\/|$)/ => "cc-by-sa",
      /creativecommons.org.*\/by(\/|$)/ => "cc-by",
      /(data|nationalarchives).gov.uk.*\/open-government-licence(\/|$)/ => "ogl-uk",
      /usa.gov\/publicdomain(\/|$)/ => "us-pd"
    }

    # @!attribute is
    #   @return [String] a short ID that identifies the license.
    attr_accessor :id
    
    # @!attribute name
    #   @return [String] the human name of the license.
    attr_accessor :name
    
    # @!attribute uri
    #   @return [String] the URI for the license text.
    attr_accessor :uri

    # @!attribute type
    #   @return [String] the type of information this license applies to. Could be +:data+ or +:content+.
    attr_accessor :type
    
    # @!attribute abbr
    #   @return [String] the license abbreviation
    attr_accessor :abbr

    # Create a new License object.
    #
    # @param options [Hash] A set of options with which to initialise the license.
    # @option options [String] :id the short ID for the license
    # @option options [String] :name the human name for the license
    # @option options [String] :uri the URI of the license text
    # @option options [String] :type the type of information covered by this license.
    def initialize(options)
      @id = options[:id]
      @name = options[:name]
      @uri = options[:uri]
      @type = options[:type]
      @abbr = get_license_abbr(@uri) if @uri
    end
    
    def get_license_abbr(uri)
      license = LICENSES.find { |regex, abbr| uri =~ regex }
      license.last if license
    end

  end  

end
