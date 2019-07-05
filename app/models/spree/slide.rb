class Spree::Slide < Spree::Base
  has_and_belongs_to_many :slide_locations,
                          class_name: 'Spree::SlideLocation',
                          join_table: 'spree_slide_slide_locations'

  has_attached_file :image,
                    url: '/spree/slides/:id/:style/:basename.:extension',
                    path: ':rails_root/public/spree/slides/:id/:style/:basename.:extension',
                    convert_options: { all: '-strip -auto-orient -colorspace sRGB' }
  validates_attachment :image, content_type: { content_type: ["image/jpg", "image/jpeg", "image/png", "image/gif"] }

  scope :published, -> { where(published: true).order('position ASC') }
  scope :location, -> (location) { joins(:slide_locations).where('spree_slide_locations.name = ?', location) }
  scope :located_on, -> (*locations) do
    scope = all
    locations.each_with_index do |location, i|
      scope = scope.
                joins("join spree_slide_slide_locations ssl#{i} on ssl#{i}.slide_id = spree_slides.id").
                joins("join spree_slide_locations sl#{i} on sl#{i}.id = ssl#{i}.slide_location_id").
                where("sl#{i}.name = ?", location)
    end
    scope
  end

  belongs_to :product, touch: true, optional: true

  self.whitelisted_ransackable_associations = %w[product slide_locations]
  self.whitelisted_ransackable_attributes = %w[name published position]

  def initialize(attrs = nil)
    attrs ||= { published: true }
    super
  end

  def slide_name
    name.blank? && product.present? ? product.name : name
  end

  def slide_link
    link_url.blank? && product.present? ? product : link_url
  end

  def slide_image
    !image.file? && product.present? && product.images.any? ? product.images.first.attachment : image
  end
end
