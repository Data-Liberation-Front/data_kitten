module GuessableLookup
  def lookup(*path)
    data = self
    path.each { |key| data = guess_key(data, key) }
    data
  rescue
    nil
  end

  private

  # Guesses which key you want from a hash and returns the value of it.
  #
  # It returns the value of the original key if it exists in the hash, otherwise
  # tries to find a similar key, and if it fails it returns nil.
  # Similar keys are ones which use '_', '-' or '' as word separators & are
  # case-insensitive.
  #
  # @example
  #   guess_key({:a_key => true}, 'a_key')  # => true
  #   guess_key({:aKey => true}, 'a_key')   # => true
  #   guess_key({"a-KEY" => true}, 'a_key') # => true
  #
  # @param data [Hash]
  # @param key [String] The desired key
  # @return The value of the guessed key
  #
  def guess_key(data, key)
    return data[key] if key.is_a?(Integer) || data.keys.include?(key)
    likeKey = key.gsub(/[_\-]/, "[\_\-]?")
    key = data.keys.select { |k| k =~ /^#{likeKey}$/i }.first
    data[key]
  rescue
    nil
  end
end
