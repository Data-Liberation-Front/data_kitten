require "data_kitten/publishing_formats/datapackage"
require "data_kitten/publishing_formats/rdfa"
require "data_kitten/publishing_formats/linked_data"
require "data_kitten/publishing_formats/ckan"

module DataKitten
  module PublishingFormats
    private

    def detect_publishing_format
      [
        DataKitten::PublishingFormats::Datapackage,
        DataKitten::PublishingFormats::CKAN,
        DataKitten::PublishingFormats::RDFa,
        DataKitten::PublishingFormats::LinkedData
      ].each do |format|
        if format.supported?(self)
          extend format
          break
        end
      end
    end
  end
end
