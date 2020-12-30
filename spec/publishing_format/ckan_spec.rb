require "spec_helper"
require "ckan_fakeweb"

describe DataKitten::PublishingFormats::CKAN do
  before(:each) do
    FakeWeb.clean_registry
  end

  context "With a CKAN 2 endpoint" do
    before { CKANFakeweb.register_defence_dataset }

    it "should detect CKAN Datasets" do
      d = DataKitten::Dataset.new("http://example.org/dataset/defence")
      expect(d.publishing_format).to eql(:ckan)
      expect(d.supported?).to eql(true)
    end

    it "can have 2 instances in memory at the same time" do
      CKANFakeweb.register_toilets_dataset
      d1 = DataKitten::Dataset.new("http://example.org/dataset/defence")
      d2 = DataKitten::Dataset.new("http://example.org/dataset/toilets")
      expect(d1.data_title).to eq("Defence Infrastructure Organisation Disposals Database House of Commons Report")
      expect(d2.data_title).to eq("National Public Toilet Map")
    end

    context "when parsing CKAN" do
      before(:each) do
        @dataset = DataKitten::Dataset.new("http://example.org/dataset/defence")
      end

      it "should get the title" do
        expect(@dataset.data_title).to eql("Defence Infrastructure Organisation Disposals Database House of Commons Report")
      end

      it "should get the description" do
        expect(@dataset.description).to eql("MoD present and future disposal properties that are in the public domain that is provided for reference in the House of Commons library\r\n")
      end

      it "should get the identifier" do
        expect(@dataset.identifier).to eql("defence-infrastructure-organisation-disposals-database-house-of-commons-report")
      end

      it "should get the landing page" do
        expect(@dataset.landing_page).to eql("http://data.gov.uk/dataset/defence-infrastructure-organisation-disposals-database-house-of-commons-report")
      end

      it "should get the licence" do
        expect(@dataset.licenses.length).to eql(1)
        licence = @dataset.licenses.first
        expect(licence.uri).to eql("http://reference.data.gov.uk/id/open-government-licence")
        expect(licence.name).to eql("UK Open Government Licence (OGL)")
        expect(licence.id).to eql("uk-ogl")
      end

      it "should get the keywords" do
        expect(@dataset.keywords.length).to eql(6)
        expect(@dataset.keywords[0]).to eql("Defence")
        expect(@dataset.keywords[1]).to eql("Government")
        expect(@dataset.keywords[2]).to eql("Land and Property")
        expect(@dataset.keywords[3]).to eql("Property")
        expect(@dataset.keywords[4]).to eql("disposals")
        expect(@dataset.keywords[5]).to eql("house of commons")
      end

      it "should get the publisher" do
        expect(@dataset.publishers.length).to eql(1)
        publisher = @dataset.publishers.first
        expect(publisher.name).to eql("Defence Infrastructure Organisation")
        expect(publisher.uri).to eql("http://www.example.com")
        expect(publisher.mbox).to eql("foo@example.com")
      end

      it "gets the maintainer" do
        expect(@dataset.maintainers).to eq([DataKitten::Agent.new(name: "Mx Maintainer", mbox: "mx@maintainer.org")])
      end

      it "gets the author as a contributor" do
        expect(@dataset.contributors).to eq([DataKitten::Agent.new(name: "Mx Author", mbox: "mx@author.org")])
      end

      it "should list the distributions" do
        expect(@dataset.distributions.length).to eql(1)

        expect(@dataset.distributions.first.description).to eql("Disposals Database House of Commons Report January 2013")
        expect(@dataset.distributions.first.issued).to eql(Date.parse("2012-11-23T12:34:54.297808"))
        expect(@dataset.distributions.first.modified).to eql(Date.parse("2013-11-16T02:37:37.294479"))
        expect(@dataset.distributions.first.access_url).to eql("http://data.gov.uk/dataset/defence-infrastructure-organisation-disposals-database-house-of-commons-report")
        expect(@dataset.distributions.first.download_url).to eql("https://www.gov.uk/government/publications/disposal-database-house-of-commons-report")
        expect(@dataset.distributions.first.byte_size).to eql(23806)
        expect(@dataset.distributions.first.media_type).to eql("text/html")
      end

      it "should get the update frequency" do
        expect(@dataset.update_frequency).to eql("bi-monthly")
      end

      it "should get the issued date" do
        expect(@dataset.issued).to eql(Date.parse("2012-10-05T13:51:55.812923"))
      end

      it "should get the modified date" do
        expect(@dataset.modified).to eql(Date.parse("2013-11-16T02:37:42.408267"))
      end

      it "should get the temporal coverage" do
        temporal = @dataset.temporal
        expect(temporal.start).to eql(Date.parse("2012-11-01"))
        expect(temporal.end).to eql(Date.parse("2013-10-31"))
      end

      it "should get the theme" do
        expect(@dataset.theme).to eql("Defence")
      end
    end

    context "and CKAN is not running on the root of the domain" do
      it "loads the dataset" do
        url = CKANFakeweb.register_dataset(
          URI("http://other.org/some/path/"),
          "defence",
          load_fixture("ckan/rest-dataset-defence.json")
        )

        dataset = DataKitten::Dataset.new(url)
        expect(dataset.publishing_format).to eq(:ckan)
      end
    end
  end

  context "With a CKAN 3 endpoint" do
    before { CKANFakeweb.register_toilets_dataset }

    it "should detect CKAN Datasets" do
      d = DataKitten::Dataset.new("http://example.org/dataset/toilets")
      expect(d.publishing_format).to eql(:ckan)
      expect(d.supported?).to eql(true)
    end

    context "when the dataset has a UUID" do
      before(:each) do
        @dataset = DataKitten::Dataset.new("http://example.org/dataset/62766308-cb4f-4275-b4a4-937f52a978c5")
      end

      it "should get the title" do
        expect(@dataset.data_title).to eql("National Public Toilet Map")
      end

      it "should get the description" do
        expect(@dataset.description).to eql("Here are some notes")
      end

      it "should get the identifier" do
        expect(@dataset.identifier).to eql("national-public-toilet-map")
      end

      it "should get the landing page" do
        expect(@dataset.landing_page).to eql("http://www.toiletmap.gov.au/default.aspx")
      end

      it "should get the licence" do
        expect(@dataset.licenses.length).to eql(1)
        licence = @dataset.licenses.first
        expect(licence.uri).to eql("http://creativecommons.org/licenses/by/3.0/au/")
        expect(licence.name).to eql("Creative Commons Attribution 3.0 Australia")
        expect(licence.id).to eql("cc-by")
      end

      it "should get the keywords" do
        expect(@dataset.keywords.length).to eql(2)
        expect(@dataset.keywords[0]).to eql("health")
        expect(@dataset.keywords[1]).to eql("toilet")
      end

      it "should get the publisher" do
        expect(@dataset.publishers.length).to eql(1)
        publisher = @dataset.publishers.first
        expect(publisher.name).to eql("Department of Health and Ageing")
        expect(publisher.uri).to eql("http://www.example.com")
        expect(publisher.mbox).to eql("foo@example.com")
      end

      it "should list the distributions" do
        expect(@dataset.distributions.length).to eql(1)

        expect(@dataset.distributions.first.description).to eql("Toilet Map")
        expect(@dataset.distributions.first.issued).to eql(Date.parse("2013-05-12T08:42:48.397216"))
        expect(@dataset.distributions.first.modified).to eql(Date.parse("2013-12-10T00:35:29.489574"))
        expect(@dataset.distributions.first.access_url).to eql("http://www.toiletmap.gov.au/default.aspx")
        expect(@dataset.distributions.first.download_url).to eql("http://data.gov.au/storage/f/2013-11-14T05%3A41%3A12.200Z/toiletmapexport-131112-042111.zip")
        expect(@dataset.distributions.first.byte_size).to eql(1112225)
        expect(@dataset.distributions.first.media_type).to eql("application/zip")
      end

      it "should get the issued date" do
        expect(@dataset.issued).to eql(Date.parse("2013-05-12T08:42:38.802401"))
      end

      it "should get the modified date" do
        expect(@dataset.modified).to eql(Date.parse("2014-03-02T05:44:59.497920"))
      end

      it "should get the theme" do
        expect(@dataset.theme).to eql("community")
      end
    end

    context "when parsing CKAN" do
      before(:each) do
        @dataset = DataKitten::Dataset.new("http://example.org/dataset/toilets")
      end

      it "should get the title" do
        expect(@dataset.data_title).to eql("National Public Toilet Map")
      end

      it "should get the description" do
        expect(@dataset.description).to eql("Here are some notes")
      end

      it "should get the licence" do
        expect(@dataset.licenses.length).to eql(1)
        licence = @dataset.licenses.first
        expect(licence.uri).to eql("http://creativecommons.org/licenses/by/3.0/au/")
        expect(licence.name).to eql("Creative Commons Attribution 3.0 Australia")
        expect(licence.id).to eql("cc-by")
      end

      it "should get the keywords" do
        expect(@dataset.keywords.length).to eql(2)
        expect(@dataset.keywords[0]).to eql("health")
        expect(@dataset.keywords[1]).to eql("toilet")
      end

      it "should get the publisher" do
        expect(@dataset.publishers.length).to eql(1)
        publisher = @dataset.publishers.first
        expect(publisher.name).to eql("Department of Health and Ageing")
        expect(publisher.uri).to eql("http://www.example.com")
        expect(publisher.mbox).to eql("foo@example.com")
      end

      it "should list the distributions" do
        expect(@dataset.distributions.length).to eql(1)

        expect(@dataset.distributions.first.description).to eql("Toilet Map")
        expect(@dataset.distributions.first.issued).to eql(Date.parse("2013-05-12T08:42:48.397216"))
        expect(@dataset.distributions.first.modified).to eql(Date.parse("2013-12-10T00:35:29.489574"))
        expect(@dataset.distributions.first.access_url).to eql("http://www.toiletmap.gov.au/default.aspx")
        expect(@dataset.distributions.first.download_url).to eql("http://data.gov.au/storage/f/2013-11-14T05%3A41%3A12.200Z/toiletmapexport-131112-042111.zip")
        expect(@dataset.distributions.first.byte_size).to eql(1112225)
        expect(@dataset.distributions.first.media_type).to eql("application/zip")
      end

      it "should get the issued date" do
        expect(@dataset.issued).to eql(Date.parse("2013-05-12T08:42:38.802401"))
      end

      it "should get the modified date" do
        expect(@dataset.modified).to eql(Date.parse("2014-03-02T05:44:59.497920"))
      end

      it "should get the theme" do
        expect(@dataset.theme).to eql("community")
      end
    end
  end

  context "with cadastral dataset" do
    before { CKANFakeweb.register_cadastral_dataset }

    before(:each) do
      @dataset = DataKitten::Dataset.new("http://example.org/api/rest/package/65493c4b-46d5-4125-b7d4-fc1df2b33349")
    end

    it "should get the title" do
      expect(@dataset.data_title).to eql("LPS Cadastral Parcels NI (Metadata)")
    end

    it "should get the description" do
      expect(@dataset.description).to eql("The dataset contains the boundaries of each individual freehold title to land.")
    end

    it "should get the identifier" do
      expect(@dataset.identifier).to eql("lps-cadastral-parcels-ni-metadata")
    end

    it "should get the landing page" do
      expect(@dataset.landing_page).to eql("http://data.gov.uk/dataset/lps-cadastral-parcels-ni-metadata")
    end

    it "should get no licence" do
      expect(@dataset.licenses.length).to eql(0)
    end

    it "should get the keywords" do
      expect(@dataset.keywords.length).to eql(18)
      expect(@dataset.keywords[0]).to eql("Cadastral")
    end

    it "should get the publisher" do
      expect(@dataset.publishers.length).to eql(1)
      publisher = @dataset.publishers.first
      expect(publisher.name).to eql("Northern Ireland Spatial Data Infrastructure")
    end

    it "should list no distributions" do
      expect(@dataset.distributions.length).to eql(0)
    end

    it "should get the update frequency" do
      expect(@dataset.update_frequency).to eql("biannually")
    end

    it "should get the issued date" do
      expect(@dataset.issued).to eql(Date.parse("2012-12-21T11:41:36.523040"))
    end

    it "should get the modified date" do
      expect(@dataset.modified).to eql(Date.parse("2014-02-18T16:38:37.394178"))
    end

    it "should get the language" do
      expect(@dataset.language).to eql("eng")
    end

    it "should get the theme" do
      expect(@dataset.theme).to eql("Mapping")
    end

    it "should get the spatial coverage" do
      spatial = @dataset.spatial
      expect(spatial["type"]).to eql("Polygon")
      expect(spatial["coordinates"][0]).to include(
        [-5.2563, 53.8869],
        [-5.2563, 55.5369],
        [-8.1906, 55.5369],
        [-8.1906, 53.8869],
        [-5.2563, 53.8869]
      )
    end
  end

  context "with pollinator dataset" do
    before(:each) do
      CKANFakeweb.register_pollinator_dataset
      @dataset = DataKitten::Dataset.new("http://example.org/api/rest/package/10d394fd-88b9-489f-9552-b7b567f927e2")
    end

    it "should get the title" do
      expect(@dataset.data_title).to eql("Pollinator visitation data on oilseed rape varieties")
    end

    it "should get the description" do
      expect(@dataset.description).to start_with("This dataset contains counts of pollinators visiting different varieties of oilseed rape (OSR).")
    end

    it "should get the identifier" do
      expect(@dataset.identifier).to eql("pollinator-visitation-data-on-oilseed-rape-varieties")
    end

    it "should get the landing page" do
      expect(@dataset.landing_page).to eql("http://data.gov.uk/dataset/pollinator-visitation-data-on-oilseed-rape-varieties")
    end

    it "should get the licence" do
      expect(@dataset.licenses.length).to eql(1)
      licence = @dataset.licenses.first
      expect(licence.uri).to eql("http://eidc.ceh.ac.uk/administration-folder/tools/ceh-standard-licence-texts/ceh-open-government-licence/plain")
      expect(licence.name).to eql("This resource is made available under the terms of the Open Government Licence")
      expect(licence.id).to be_nil
    end

    it "should get the keywords" do
      expect(@dataset.keywords.length).to eql(12)
      expect(@dataset.keywords).to include("bibionidae", "bumblebees")
    end

    it "should get the publisher" do
      expect(@dataset.publishers.length).to eql(1)
      publisher = @dataset.publishers.first
      expect(publisher.name).to eql("Centre for Ecology & Hydrology")
    end

    it "should list the distributions" do
      expect(@dataset.distributions.length).to eql(2)

      expect(@dataset.distributions.first.description).to start_with("Supporting information")
      expect(@dataset.distributions.first.issued).to eql(Date.parse("2015-08-17T16:29:04.843110"))
      expect(@dataset.distributions.first.modified).to be_nil
      expect(@dataset.distributions.first.access_url).to eql("http://data.gov.uk/dataset/pollinator-visitation-data-on-oilseed-rape-varieties")
      expect(@dataset.distributions.first.download_url).to eql("http://eidc.ceh.ac.uk/metadata/d7b25308-3ec7-4cff-8eed-fe20b815f964/zip_export")
      expect(@dataset.distributions.first.byte_size).to be_nil
      expect(@dataset.distributions.first.media_type).to be_nil
    end

    it "should get the update frequency" do
      expect(@dataset.update_frequency).to eql("notPlanned")
    end

    it "should get the issued date" do
      expect(@dataset.issued).to eql(Date.parse("2014-08-11T08:29:37.215826"))
    end

    it "should get the modified date" do
      expect(@dataset.modified).to eql(Date.parse("2015-08-17T15:29:04.733151"))
    end

    it "should get the language" do
      expect(@dataset.language).to eql("eng")
    end

    it "should get the theme" do
      expect(@dataset.theme).to eql("Environment")
    end

    it "should get the temporal coverage" do
      temporal = @dataset.temporal
      expect(temporal.start).to eql(Date.parse("2012-05-01"))
      expect(temporal.end).to eql(Date.parse("2012-05-31"))
    end

    it "should get the spatial coverage" do
      spatial = @dataset.spatial
      expect(spatial["type"]).to eql("Polygon")
      east = 1.5329
      north = 53.206
      south = 51.616
      west = -1.095
      expect(spatial["coordinates"][0]).to eql([
        [west, north],
        [east, north],
        [east, south],
        [west, south],
        [west, north]
      ])
    end
  end

  context "when a v3 api url is provided" do
    let(:dataset) do
      CKANFakeweb.register_frozen_animals_dataset
      DataKitten::Dataset.new("http://example.org/api/3/action/package_show?id=frozen-animals")
    end

    it "loads the dataset" do
      expect(dataset.publishing_format).to eql(:ckan)
      expect(dataset.supported?).to eql(true)
    end

    it "converts extras to a hash" do
      expect(dataset.metadata["extras"].keys).to include("geographic_coverage", "temporal_coverage-from", "theme-primary")
    end

    it "converts tags to a list" do
      expect(dataset.metadata["tags"]).to include("Environment")
    end

    it "defauls publisher url to base url if missing from organization" do
      expect(dataset.publishers[0].homepage).to eq("http://example.org/")
    end
  end

  context "when a 'rest' api url is provided" do
    it "loads the dataset" do
      CKANFakeweb.register_defence_dataset
      d = DataKitten::Dataset.new("http://example.org/api/2/rest/dataset/defence")
      expect(d.publishing_format).to eql(:ckan)
      expect(d.supported?).to eql(true)
    end
  end

  context "when not on the root of a domain" do
    it "accepts a specified base_uri for v3" do
      CKANFakeweb.register_frozen_animals_dataset("http://example.net/hidden_ckan/")
      d = DataKitten::Dataset.new("http://example.net/hidden_ckan/api/3/action/package_show?id=frozen-animals", "http://example.net/hidden_ckan/")
      expect(d.publishing_format).to eql(:ckan)
      expect(d.supported?).to eql(true)
    end

    it "accepts a specified base_uri for 'rest'" do
      CKANFakeweb.register_defence_dataset("http://example.net/hidden_ckan/")
      d = DataKitten::Dataset.new("http://example.net/hidden_ckan/api/2/rest/dataset/defence", "http://example.net/hidden_ckan/")
      expect(d.publishing_format).to eql(:ckan)
      expect(d.supported?).to eql(true)
    end
  end
end
