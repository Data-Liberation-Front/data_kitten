require 'spec_helper'

describe DataKitten::DistributionFormat do

  def distribution(extension)
    DataKitten::Distribution.new(nil,
      ckan_resource: {
        format: extension
      })
  end

  describe '#structured?' do
    %w[csv xls xlsx rdf xml wms ods rdfa kml rss json ical sparql kml georss geojson shp].each do |ext|
      it "considers #{ext} structured" do
        expect(distribution(ext).format).to be_structured
      end
    end

    %w[html doc pdf unknown].each do |ext|
      it "considers #{ext} not structured" do
        expect(distribution(ext).format).to_not be_structured
      end
    end
  end

  describe '#open?' do
    %w[csv xlsx rdf xml wms ods rdfa kml rss json ical sparql kml georss geojson shp html pdf].each do |ext|
      it "considers #{ext} open" do
        expect(distribution(ext).format).to be_open
      end
    end

    %w[doc unknown].each do |ext|
      it "considers #{ext} not open" do
        expect(distribution(ext).format).to_not be_open
      end
    end
  end
end
