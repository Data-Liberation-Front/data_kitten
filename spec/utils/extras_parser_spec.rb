require 'data_kitten/utils/extras_parser'

describe DataKitten::Utils do

  context 'with an array of key-value dicts' do

    subject(:extras) {
      DataKitten::Utils.parse_extras([
        { "key" => "somekey", "value" => "somevalue" }
      ])
    }

    it { should be_a Hash }
    it { should eql({ "somekey" => "somevalue" }) }

  end

  context 'with a hash' do

    subject(:extras) {
      DataKitten::Utils.parse_extras({
        "somekey" => "somevalue"
      })
    }

    it { should be_a Hash }
    it { should eql({ "somekey" => "somevalue" }) }

  end
end
