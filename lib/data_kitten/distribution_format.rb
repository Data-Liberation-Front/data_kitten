module DataKitten

  # A file format for a distribution
  # 
  # For instance CSV, XML, etc.
  #
  class DistributionFormat
   
    #@!attribute extension
    #@return [Symbol] a symbol for the file extension. For instance, :csv.
    attr_reader :extension

    # Create a new DistributionFormat object with the relevant extension
    #
    # @param extension [String] the file extension for the format
    def initialize(extension)
      # Store extension as a lowercase symbol
      @extension = extension.to_s.downcase.to_sym
      # Set up format lists
      @@formats ||= {
        csv:     { structured:  true, open:  true },
        xls:     { structured:  true, open: false },
        rdf:     { structured:  true, open:  true },
        xml:     { structured:  true, open:  true },
        wms:     { structured:  true, open:  true },
        ods:     { structured:  true, open:  true },
        rdfa:    { structured:  true, open:  true },
        kml:     { structured:  true, open:  true },
        rss:     { structured:  true, open:  true },
        json:    { structured:  true, open:  true },
        ical:    { structured:  true, open:  true },
        sparql:  { structured:  true, open:  true },
        kml:     { structured:  true, open:  true },
        georss:  { structured:  true, open:  true },
        shp:     { structured:  true, open:  true },
        html:    { structured: false, open:  true },
        doc:     { structured: false, open:  false },
        pdf:     { structured: false, open:  true },  
      }
    end

    # Is this a structured format?
    #
    # @return [Boolean] whether the format is machine-readable or not.
    def structured?
      @@formats[@extension][:structured]
    end

    # Is this an open format?
    #
    # @return [Boolean] whether the format is open or not
    def open?
      @@formats[@extension][:open]
    end

  end  

end
