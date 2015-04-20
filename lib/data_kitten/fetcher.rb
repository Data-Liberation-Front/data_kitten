module DataKitten

  class Fetcher

    attr_reader :url

    def self.wrap(url_or_fetcher)
      if url_or_fetcher.is_a?(self)
        url_or_fetcher
      else
        new(url_or_fetcher)
      end
    end

    def initialize(url)
      @url = url
    end

    def ok?
      code == 200
    end

    def code
      response ? response.code : @code
    end

    def body
      response if response
    end

    def as_json
      JSON.parse(body) if response
    rescue JSON::ParserError
      nil
    end

    def content_type
      response.headers[:content_type] if response
    end

    def content_type_format
      if val = content_type
        val.split(';').first
      end
    end

    def to_s
      url.to_s
    end

    def html?
      !!(content_type_format =~ %r{^text/html}i)
    end

    private
    def response
      unless @requested
        @requested = true
        begin
          @response = RestClient.get(url)
        rescue RestClient::ExceptionWithResponse => error
          @error = error.response
          @code = @error.code
        end
      end
      @response
    end
  end
  
end
