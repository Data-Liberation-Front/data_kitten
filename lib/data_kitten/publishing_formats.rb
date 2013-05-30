require 'data_kitten/publishing_formats/datapackage'
require 'data_kitten/publishing_formats/rdfa'

module DataKitten
  
  module PublishingFormats

    private

    def detect_publishing_format
      [
        DataKitten::PublishingFormats::Datapackage,
        DataKitten::PublishingFormats::RDFa
      ].each do |format|
        extend format if format.supported?(self)
      end
    end

  end
  
end
