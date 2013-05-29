module DataKitten
  
  module Origins
    
    # Web service origin module. Automatically mixed into {Dataset} for datasets that are accessed through an API.
    #
    # @see Dataset
    #
    module WebService
  
      private
  
      def self.supported?(uri)
        false
      end

      public

      # The origin type of the dataset.
      # @return [Symbol] +:web_service+
      # @see Dataset#origin
      def origin
        :web_service
      end

    end

  end

end