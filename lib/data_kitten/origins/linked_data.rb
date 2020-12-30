module DataKitten
  module Origins
    # Linked Data origin module. Automatically mixed into {Dataset} for datasets that are accessed through an API.
    #
    # @see Dataset
    #
    module LinkedData
      def self.supported?(resource)
        if (type = resource.content_type_format)
          RDF::Format.content_types.key?(type)
        end
      end

      # The origin type of the dataset.
      # @return [Symbol] +:linkeddata+
      # @see Dataset#origin
      def origin
        :linkeddata
      end
    end
  end
end
