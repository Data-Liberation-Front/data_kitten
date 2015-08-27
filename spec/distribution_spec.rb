require 'spec_helper'

describe DataKitten::Distribution do
  before(:all) do
    FakeWeb.allow_net_connect = false
    FakeWeb.clean_registry
    # Defence dataset
    @urls = {
      "/dataset/defence" => {
        :body => "",
        :content_type => "text/html"
      },
      "/api/3/action/package_show?id=defence" => {
        :body => "",
        :content_type => "application/json"
      },
      "/api/2/rest/dataset/defence" => {
        :body => load_fixture("ckan/rest-dataset-defence.json"),
        :content_type => "application/json"
      },
      "/api/2/search/dataset?q=defence" => {
        :body => load_fixture("ckan/rest-dataset-defence.json"),
        :content_type => "application/json"
      },
      "/api/rest/package/47f7438a-506d-49c9-b565-7573f8df031e" => {
        :body => load_fixture("ckan/rest-dataset-defence.json"),
        :content_type => "application/json"
      }
    }

    @urls.each do |path, options|
      FakeWeb.register_uri(:get, "http://example.org#{path}", options)
    end
  end

  let(:dataset) do
    DataKitten::Dataset.new( access_url: "http://example.org/dataset/defence")
  end

  subject(:distribution) { dataset.distributions[0] }

  it { expect(distribution).to_not be_nil }

  describe 'exists?' do
    it 'exists when available' do
      FakeWeb.register_uri(:head, "https://www.gov.uk/government/publications/disposal-database-house-of-commons-report", body: "hi")

      expect(distribution).to be_exists
    end

    it 'does not exist when missing' do
      FakeWeb.register_uri(:head, "https://www.gov.uk/government/publications/disposal-database-house-of-commons-report", status: 404)

      expect(distribution).to_not be_exists
    end
  end

  describe 'data' do
    it 'fetches csv data' do
      csv = CSV.generate do |c|
        c << %w[one two three]
        c << %w[1 2 3]
      end
      FakeWeb.register_uri(:get, "https://www.gov.uk/government/publications/disposal-database-house-of-commons-report", body: csv)

      expect(distribution.data).to eq(CSV.parse(csv, headers: true))
    end
  end

end
