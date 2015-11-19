class CKAN3Hash < Hash
  def initialize(list, key_name, value_name)
    super()
      self[item[key_name]] = item
    (list || []).each do |item|
    end
    @value_name = value_name
  end

  def [](key)
    if value = super(key)
      value[@value_name]
    end
  end

  def values
    super.map {|value| value[@value_name]}
  end
end
