require 'spec_helper'

describe DataKitten::Fetcher do

  before(:each) do
    FakeWeb.clean_registry
  end

  describe 'wrapping returns same instance' do
    before do
      FakeWeb.register_uri(:get, "http://example.org/resource", :body=> "<p>text</p>", :content_type=>"text/html; encoding=utf-8")
    end
    subject(:resource) { described_class.new("http://example.org/resource") }

    it { should eq(DataKitten::Fetcher.wrap(resource)) }
    it "should not request again" do
      expect(resource).to be_ok
      new_resource = DataKitten::Fetcher.wrap(resource)
      FakeWeb.clean_registry
      expect(new_resource).to be_ok
    end
  end

  it 'follows redirects' do
    FakeWeb.register_uri(:get, "http://example.org/resource", :status => 301, :location => "http://example.org/dataset")
    FakeWeb.register_uri(:get, "http://example.org/dataset", :body=> "<p>text</p>")

    resource = DataKitten::Fetcher.wrap("http://example.org/resource")
    expect(resource.body).to eq("<p>text</p>")
  end

  describe 'existence checks' do
    subject(:resource) { described_class.new("http://example.org/dataset") }

    it 'makes a head request by default' do
      FakeWeb.register_uri(:head, "http://example.org/dataset", :body => "<p>text</p>")
      expect(resource).to be_exists
    end

    it 'reuses response code if already fetched' do
      FakeWeb.register_uri(:get, "http://example.org/dataset", :body => "<p>text</p>")
      resource.ok?
      expect(resource).to be_exists
    end

    it 'handles a not found' do
      FakeWeb.register_uri(:head, "http://example.org/dataset", :status => 404)
      expect(resource).to_not be_exists
    end
  end

  describe 'present resource' do
    before do
      FakeWeb.register_uri(:get, "http://example.org/resource", :body=> "<p>text</p>", :content_type=>"text/html; encoding=utf-8")
    end
    subject(:resource) { described_class.new("http://example.org/resource") }

    it { should be_ok }
    it { expect(resource.code).to eq(200) }
    it { expect(resource.body).to eq("<p>text</p>") }
    it { expect(resource.as_json).to be_nil }
    it { should be_html }
    it { expect(resource.content_type).to eq("text/html; encoding=utf-8") }
    it { expect(resource.content_type_format).to eq("text/html") }
    it { expect(resource.to_s).to eq("http://example.org/resource") }
  end

  describe 'present json resource' do
    before do
      FakeWeb.register_uri(:get, "http://example.org/resource", :body=> '{"hi":"there"}', :content_type=>"application/json; encoding=utf-8")
    end
    subject(:resource) { described_class.new("http://example.org/resource") }

    it { should be_ok }
    it { expect(resource.code).to eq(200) }
    it { should_not be_html }
    it { should be_json }
    it { expect(resource.as_json).to eq({"hi" => "there"}) }
    it { expect(resource.content_type).to eq("application/json; encoding=utf-8") }
    it { expect(resource.content_type_format).to eq("application/json") }
    it { expect(resource.to_s).to eq("http://example.org/resource") }
  end

  describe 'not found' do
    before do
      FakeWeb.register_uri(:get, "http://example.org/not-found", :status => ["404", "Not Found"])
    end
    subject(:resource) { described_class.new("http://example.org/not-found") }

    it { should_not be_ok }
    it { expect(resource.code).to eq(404) }
  end

end
