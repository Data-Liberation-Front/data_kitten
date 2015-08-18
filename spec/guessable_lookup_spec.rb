require 'spec_helper'
require 'data_kitten/utils/guessable_lookup'

describe GuessableLookup do

  context 'with a hash that has an exact key' do
    before do
      @hash = {
        "some_key" => "some_key",
        "another_key" => "another_key"
      }.extend(GuessableLookup)
    end

    it 'returns exact key' do
      expect(@hash.lookup("some_key")).to eq("some_key")
    end
  end

  context 'with a hash that has a similar key' do
    before do
      @hash = {
        "someKey" => "someKey"
      }.extend(GuessableLookup)
    end

    it 'returns similar key' do
      expect(@hash.lookup("some_key")).to eq("someKey")
      expect(@hash.lookup("some-key")).to eq("someKey")
      expect(@hash.lookup("somekey")).to eq("someKey")
    end
  end

  context 'with a hash that has an exact and similar key' do
    before do
      @hash = {
        "someKey" => "someKey",
        "some-key" => "some-key",
        "some_key" => "some_key"
      }.extend(GuessableLookup)
    end

    it 'returns exact key' do
      expect(@hash.lookup("someKey")).to eq("someKey")
      expect(@hash.lookup("some_key")).to eq("some_key")
      expect(@hash.lookup("some-key")).to eq("some-key")
    end
  end

  context 'with a hash that doesn\'t have an exact or similar key' do
    before do
      @hash = {
        "someKeyy" => "someKeyy",
        "ssomeKey" => "ssomeKey",
        "some_keyy" => "some_keyy"
      }.extend(GuessableLookup)
    end

    it 'returns nil' do
      expect(@hash.lookup("some_key")).to be_nil
      expect(@hash.lookup("some-key")).to be_nil
      expect(@hash.lookup("someKey")).to be_nil
      expect(@hash.lookup("somekey")).to be_nil
    end
  end

  context 'with a nested hash' do
    before do
      @hash = {
        "some_key" => {
          "anotherKey" => true
        }
      }.extend(GuessableLookup)
    end

    it 'returns nested key' do
      expect(@hash.lookup("some_key", "anotherKey")).to be true
      expect(@hash.lookup("some-key", "another_key")).to be true
    end

    it 'returns nil for missing key' do
      expect(@hash.lookup("some-key", "anothey_key", "third_key")).to be_nil
      expect(@hash.lookup("a", "b", "c")).to be_nil
      expect(@hash.lookup("a", 0, "c")).to be_nil
    end
  end

  context 'with a hash containing array' do
    before do
      @hash = {
        "some_key" => [0,1,2]
      }.extend(GuessableLookup)
    end

    it 'returns array value' do
      expect(@hash.lookup("some_key", 0)).to eq(0)
    end

    it 'returns nil for missing key' do
      expect(@hash.lookup("some-key", 3)).to be_nil
      expect(@hash.lookup("some-key", 3, "another_key")).to be_nil
      expect(@hash.lookup("some-key", "another_key")).to be_nil
    end
  end

  context 'with a hash containing an array containig a hash' do
    before do
      @hash = {
        "some_key" => [{
          "another_key" => true
        }]
      }.extend(GuessableLookup)
    end

    it 'returns key of hash within array' do
      expect(@hash.lookup("some_key", 0, "another_key")).to be true
    end

    it 'returns nil for missing key' do
      expect(@hash.lookup("some_key", 3)).to be_nil
      expect(@hash.lookup("some_key", 0, "some_key")).to be_nil
      expect(@hash.lookup("some_key", 0, "another_key", 1)).to be_nil
    end
  end

end
