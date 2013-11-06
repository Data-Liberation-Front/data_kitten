module DataKitten
  
  module Origins
    
    # Linked Data origin module. Automatically mixed into {Dataset} for datasets that are accessed through an API.
    #
    # @see Dataset
    #
    module LinkedData
  
      private
  
      def self.supported?(uri)
        content_type = RestClient.head(uri).headers[:content_type]
        return nil unless content_type
        
        return RDF::Format.content_types.keys.include?( 
            content_type.split(";").first )    
            
      rescue
          false
      end

      public

      # The origin type of the dataset.
      # @return [Symbol] +:linkeddata+
      # @see Dataset#origin
      def origin
        :linkeddata
      end

    end

  end

end