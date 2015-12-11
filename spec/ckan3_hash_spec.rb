require 'spec_helper'

describe CKAN3Hash do

  subject(:hash) { CKAN3Hash.new(data, "name", "display_name") }

  it 'has keys based on provided data' do
    keys = %w[transportation planned_roadworks highways_agency roadworks]
    expect(hash.keys).to contain_exactly(*keys)
  end

  it 'returns the value_key value' do
    expect(hash['transportation']).to eq "Transportation"
    expect(hash['highways_agency']).to eq "Highways Agency"
    expect(hash['roadworks']).to eq "Roadworks"
    expect(hash['planned_roadworks']).to eq "Planned Roadworks"
  end

  it 'returns nil for unknown key' do
    expect(hash['mystery']).to be_nil
  end

  it 'can be constructed with nil data' do
    expect { CKAN3Hash.new(nil, 'key', 'value') }.to_not raise_error
  end

  it 'maps values' do
    values = ["Transportation", "Highways Agency", "Roadworks", "Planned Roadworks"]
    expect(hash.values).to contain_exactly(*values)
  end

  let(:data) do
    [
      {
        "vocabulary_id" => nil,
        "display_name" => "Transportation",
        "name" => "transportation",
        "revision_timestamp" => "2012-06-29T10:29:59.119372",
        "state" => "active",
        "id" => "423aad62-c714-45b6-9f9b-1b8fe4933ae1"
      },
      {
        "vocabulary_id" => nil,
        "display_name" => "Highways Agency",
        "name" => "highways_agency",
        "revision_timestamp" => "2011-10-25T15:58:51.324189",
        "state" => "active",
        "id" => "37c942e9-a9a7-4409-a46b-7b941e1591dc"
      },
      {
        "vocabulary_id" => nil,
        "display_name" => "Planned Roadworks",
        "name" => "planned_roadworks",
        "revision_timestamp" => "2011-10-25T15:58:51.324189",
        "state" => "active",
        "id" => "97b6c453-1ba1-416d-be24-1f484a1e80e0"
      },
      {
        "vocabulary_id" => nil,
        "display_name" => "Roadworks",
        "name" => "roadworks",
        "revision_timestamp" => "2011-10-25T15:58:51.324189",
        "state" => "active",
        "id" => "7fa99a87-10e8-41fe-b02b-f518cb8da1ed"
      }
    ]
  end
end
