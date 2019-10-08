module Spree
  class Slide < Base
    module Configuration
      module ActiveStorage
        extend ActiveSupport::Concern

        included do
          has_one_attached :image

          validate :check_attachment_content_type

          def accepted_image_types
            %w(image/jpeg image/jpg image/png image/gif)
          end

          def check_attachment_content_type
            if image.attached? && !image.content_type.in?(accepted_image_types)
              image.purge
              errors.add(:image, :not_allowed_content_type)
            end
          end

          def image_present?
            image.attached?
          end

          def slide_image_variant(style = nil)
            slide_image
          end
        end
      end
    end
  end
end
