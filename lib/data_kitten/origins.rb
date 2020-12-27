require 'data_kitten/origins/git'
require 'data_kitten/origins/web_service'
require 'data_kitten/origins/html'
require 'data_kitten/origins/json'
require 'data_kitten/origins/linked_data'

module DataKitten

  module Origins

    private

    def detect_origin
      [
        DataKitten::Origins::Git,
        DataKitten::Origins::HTML,
        DataKitten::Origins::JSON,
        DataKitten::Origins::WebService,
        DataKitten::Origins::LinkedData,
      ].each do |origin|
        if origin.supported?(@access_url)
          extend origin
          break
        end
      end
    end

  end

end
