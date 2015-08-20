require 'spec_helper'

describe DataKitten::License do

  describe 'with known licenses' do
    
    known_licenses = {
      "http://www.opendefinition.org/licenses/cc-by" => "cc-by",
      "http://www.opendefinition.org/licenses/cc-by/" => "cc-by",
      "http://www.opendefinition.org/licenses/cc-by-sa" => "cc-by-sa",
      "http://www.opendefinition.org/licenses/gfdl" => "gfdl",
      "http://www.opendefinition.org/licenses/odc-pddl" => "odc-pddl",
      "http://www.opendefinition.org/licenses/cc-zero" => "cc-zero",
      "http://www.nationalarchives.gov.uk/doc/open-government-licence/version/3/" => "ogl-uk",
      "http://reference.data.gov.uk/id/open-government-licence" => "ogl-uk"
    }
    
    it 'should supply abbreviation' do
      known_licenses.each do |uri, abbr|
        expect(described_class.new(:uri => uri).abbr).to eq(abbr)
      end
    end
  end
  
  describe 'with an unknown license' do
    it 'should not provide an abbreviation' do
      expect(described_class.new(:uri => "http://made-up-cc-by-sa.com/cc-by").abbr).to be_nil
    end
  end

end
