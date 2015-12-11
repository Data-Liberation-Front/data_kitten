class CKAN3Hash < Hash
  def initialize(list, key_name, value_name)
    super()
    (list || []).each do |item|
      self[item[key_name]] = item[value_name]
    end
  end
end
