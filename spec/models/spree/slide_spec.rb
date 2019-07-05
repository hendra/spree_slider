require 'spec_helper'

describe Spree::Slide, :type => :model do
  describe '::located_on' do
    let(:location_1) { Spree::SlideLocation.create! name: 'Location 1' }
    let(:location_2) { Spree::SlideLocation.create! name: 'Location 2' }
    let!(:slide_1) { Spree::Slide.create! slide_locations: [location_1] }
    let!(:slide_1_2) { Spree::Slide.create! slide_locations: [location_1, location_2] }

    it 'returns slides that have all specified locations' do
      expect(Spree::Slide.located_on 'Location 1').to eq [slide_1, slide_1_2]
      expect(Spree::Slide.located_on 'Location 1', 'Location 2').to eq [slide_1_2]
      expect(Spree::Slide.located_on 'Location 1', 'Location 2', 'Location 3').to be_empty
    end
  end
end