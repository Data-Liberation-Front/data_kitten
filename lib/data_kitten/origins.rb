require 'data_kitten/origins/git'
require 'data_kitten/origins/web_service'
require 'data_kitten/origins/html'

module DataKitten
  
  module Origins

    private

    def detect_origin
      [
        DataKitten::Origins::Git,
        DataKitten::Origins::HTML,
        DataKitten::Origins::WebService
      ].each do |origin|
        extend origin if origin.supported?(@access_url)
      end
    end

  end
  
end
