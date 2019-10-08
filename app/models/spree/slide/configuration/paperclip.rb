module Spree
  class Slide < Base
    module Configuration
      module Paperclip
        extend ActiveSupport::Concern

        included do
          def self.accepted_image_types
            %w(image/jpeg image/jpg image/png image/gif)
          end

          has_attached_file :image,
            url: '/spree/slides/:id/:style/:basename.:extension',
            path: ':rails_root/public/spree/slides/:id/:style/:basename.:extension',
            convert_options: { all: '-strip -auto-orient -colorspace sRGB' }

          delegate :url, to: :image

          validates_attachment :image, content_type: { content_type: accepted_image_types }

          def image_present?
            image.present?
          end

          def slide_image_variant(style = nil)
            slide_image&.url(style)
          end
        end
      end
    end
  end
end
