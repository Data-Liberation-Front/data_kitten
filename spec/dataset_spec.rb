require 'spec_helper'

describe DataKitten::Dataset do

  before :all do
    FakeWeb.clean_registry
    FakeWeb.allow_net_connect = false
  end

  describe 'with a supported format' do
    before do
      datapackage = load_fixture("datapackage.json")
      FakeWeb.register_uri(:get, "http://example.org/datapackage.json", :body => datapackage, :content_type => "application/json")
      @dataset = DataKitten::Dataset.new( access_url: "http://example.org/datapackage.json")
      @source = JSON.parse(datapackage)
    end

    it 'returns the original source' do
      expect( @dataset.source ).to eql(@source)
    end
  end

  describe 'with an unsupported format' do
    before do
      FakeWeb.register_uri(:get, "http://example.org/something.html", :body => "", :content_type => "text/html")
      @dataset = DataKitten::Dataset.new( access_url: "http://example.org/something.html")
    end

    it 'returns nil' do
      expect( @dataset.source ).to be_nil
    end
  end

  describe 'when resource does not exist' do
    before do
      FakeWeb.register_uri(:get, "http://example.org/something.html", :body => "Not found", :status => [404, "Not found"])
      @dataset = DataKitten::Dataset.new( access_url: "http://example.org/something.html")
    end

    it 'returns nil' do
      expect( @dataset.source ).to be_nil
    end
  end

end
