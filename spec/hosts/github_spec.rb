require 'spec_helper'

describe DataKitten::Dataset do

  context 'with data on github' do

    def access_url(protocol)
      "#{protocol}://github.com/theodi/github-viewer-test-data.git"
    end

    %w[https http git].each do |protocol|
      it "correctly identified #{protocol} URLs p" do
        dataset = DataKitten::Dataset.new(access_url(protocol))
        expect(dataset.host).to eq(:github)
      end
    end

  end

end
