require 'spec_helper'

describe 'Slide index', type: :feature do
  stub_authorization!

  let(:product) { create :product }
  let(:location_1) { Spree::SlideLocation.create! name: 'Location 1' }
  let(:location_2) { Spree::SlideLocation.create! name: 'Location 2' }
  let(:slide_1) do
    Spree::Slide.create! name: 'Slide 1', published: false, product: product, slide_locations: [location_1]
  end
  let(:slide_2) { Spree::Slide.create! name: 'Slide 2', published: true, slide_locations: [location_2] }

  before do
    slide_1
    slide_2
    visit spree.admin_slides_path
  end

  it 'lists existing slides' do
    within_row(1) do
      expect(column_text(3)).to eq 'Slide 1'
      expect(column_text(4)).to eq product.name
      expect(column_text(5)).to eq 'Location 1'
      expect(column_text(6)).to eq 'No'
    end

    within_row(2) do
      expect(column_text(3)).to eq 'Slide 2'
      expect(column_text(4)).to be_blank
      expect(column_text(5)).to eq 'Location 2'
      expect(column_text(6)).to eq 'Yes'
    end
  end

  it 'is able to sort the slides listing' do
    click_link 'Name'

    within_row(1) { expect(page).to have_content('Slide 1') }
    within_row(2) { expect(page).to have_content('Slide 2') }

    click_link 'Product'
    click_link 'Product'

    within_row(1) { expect(page).to have_content('Slide 2') }
    within_row(2) { expect(page).to have_content('Slide 1') }

    click_link 'Published'

    within_row(1) { expect(page).to have_content('Slide 1') }
    within_row(2) { expect(page).to have_content('Slide 2') }
  end

  describe 'searching slides' do
    it 'is able to search slides by name' do
      fill_in 'q_name_cont', with: 'slide 2'
      click_on 'Filter Results'

      within_row(1) do
        expect(page).to have_content('Slide 2')
      end

      within('table#listing_slides') { expect(page).not_to have_content('Slide 1') }
    end

    it 'is able to search slides by product name' do
      click_on 'Filter'
      fill_in 'q_product_name_cont', with: product.name
      click_on 'Filter Results'

      within_row(1) do
        expect(page).to have_content('Slide 1')
      end

      within('table#listing_slides') { expect(page).not_to have_content('Slide 2') }
    end

    it 'is able to search slides by slide location' do
      click_on 'Filter'
      select 'Location 1', from: 'Location'
      click_on 'Filter Results'

      within_row(1) do
        expect(page).to have_content('Slide 1')
      end

      within('table#listing_slides') { expect(page).not_to have_content('Slide 2') }
    end

    it 'is able to search published slides' do
      click_on 'Filter'
      check 'q_published_eq'
      click_on 'Filter Results'

      within_row(1) do
        expect(page).to have_content('Slide 2')
      end

      within('table#listing_slides') { expect(page).not_to have_content('Slide 1') }
    end
  end
end