require 'spec_helper'

describe DataKitten::Dataset do

  before :all do
    @r = DataKitten::Dataset.new(access_url: "http://github.com/theodi/github-viewer-test-data.git")
  end

  # it "can generate a stripped version of the uri for descriptions and links" do
  #   @r.stripped_uri.should == 'github.com/theodi/github-viewer-test-data'
  # end

  context 'with data on github' do

    it 'correctly identified https URLs' do
      r = DataKitten::Dataset.new(access_url: "https://github.com/theodi/github-viewer-test-data.git")
      expect(r.host).to eq(:github)
    end
    
    it 'correctly identified http URLs' do
      r = DataKitten::Dataset.new(access_url: "http://github.com/theodi/github-viewer-test-data.git")
      expect(r.host).to eq(:github)
    end
    
    it 'correctly identified git URLs' do
      r = DataKitten::Dataset.new(access_url: "git://github.com/theodi/github-viewer-test-data.git")
      expect(r.host).to eq(:github)
    end

  end
  
end
