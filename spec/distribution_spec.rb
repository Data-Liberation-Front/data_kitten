require 'spec_helper'
require 'ckan_fakeweb'

describe DataKitten::Distribution do
  before(:each) do
    FakeWeb.clean_registry
    CKANFakeweb.register_defence_dataset
  end

  let(:dataset) do
    DataKitten::Dataset.new("http://example.org/dataset/defence")
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
