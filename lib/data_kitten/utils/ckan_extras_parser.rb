module DataKitten

  module Utils

    def parse_extras(extras)
      if extras.is_a? Hash
        extras
      elsif extras.is_a? Array
        parse_extras_array(extras)
      end
    end

    private

    def parse_extras_array(extras_array)
      hash = {}
      extras_array.each do |item|
        hash[item["key"]] = begin
          JSON.parse item["value"]
        rescue JSON::ParserError
          item["value"]
        end
      end
      extras
    end

  end

end
