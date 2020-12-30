require "spec_helper"
require "ckan_fakeweb"

describe DataKitten::Dataset do
  before :each do
    FakeWeb.clean_registry
  end

  describe "constructing a dataset" do
    before { CKANFakeweb.register_defence_dataset }
    let(:url) { "http://example.org/dataset/defence" }
    let(:base) { "http://example.org/" }

    it "accepts access_url symbol option" do
      dataset = DataKitten::Dataset.new(access_url: url)
      expect(dataset.publishing_format).to eql(:ckan)
    end

    it "accepts url option" do
      dataset = DataKitten::Dataset.new(url)
      expect(dataset.publishing_format).to eql(:ckan)
    end

    it "finds default base_uri" do
      dataset = DataKitten::Dataset.new(url)
      expect(dataset.base_uri).to eql(URI("http://example.org/"))
    end

    it "accepts a url and base url" do
      dataset = DataKitten::Dataset.new(url, base)
      expect(dataset.uri).to eql(URI(url))
      expect(dataset.base_uri).to eql(URI(base))
    end

    it "accepts access_url and base_url options" do
      dataset = DataKitten::Dataset.new(access_url: url, base_url: base)
      expect(dataset.uri).to eql(URI(url))
      expect(dataset.base_uri).to eql(URI(base))
    end
  end

  describe "with a supported format" do
    it "returns the original source" do
      datapackage = load_fixture("datapackage.json")
      FakeWeb.register_uri(:get, "http://example.org/datapackage.json", body: datapackage, content_type: "application/json")
      dataset = DataKitten::Dataset.new("http://example.org/datapackage.json")
      source = JSON.parse(datapackage)
      expect(dataset.source).to eql(source)
    end

    it "returns the ckan api source after lookup" do
      CKANFakeweb.register_defence_dataset
      data = JSON.parse(load_fixture("ckan/rest-dataset-defence.json"))
      dataset = DataKitten::Dataset.new("http://example.org/dataset/defence")
      expect(dataset.source).to eql(data)
    end
  end

  describe "with an unsupported format" do
    before do
      FakeWeb.register_uri(:get, "http://example.org/something.html", body: "", content_type: "text/html")
      @dataset = DataKitten::Dataset.new("http://example.org/something.html")
    end

    it "returns nil" do
      expect(@dataset.source).to be_nil
    end
  end

  describe "when resource does not exist" do
    before do
      FakeWeb.register_uri(:get, "http://example.org/something.html", body: "Not found", status: [404, "Not found"])
      @dataset = DataKitten::Dataset.new("http://example.org/something.html")
    end

    it "returns nil" do
      expect(@dataset.source).to be_nil
    end
  end
end
