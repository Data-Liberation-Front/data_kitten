module DataKitten
  module Origins
    # JSON origin module. Automatically mixed into {Dataset} for datasets that are accessed through an API.
    #
    # @see Dataset
    #
    module JSON
      private

      def self.supported?(resource)
        resource.json?
      end

      public

      # The origin type of the dataset.
      # @return [Symbol] +:html+
      # @see Dataset#origin
      def origin
        :json
      end
    end
  end
end
