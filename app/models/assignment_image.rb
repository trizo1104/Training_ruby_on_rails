class AssignmentImage < ApplicationRecord
  ALLOWED_IMAGE_TYPES = %w[
    image/jpeg
    image/png
    image/webp
  ].freeze

  MAX_IMAGE_SIZE = 10.megabytes

  belongs_to :assignment

  has_one_attached :image

  validates :position, presence: true

  validate :image_is_valid


  private

  def image_is_valid
    return unless image.attached?

    unless ALLOWED_IMAGE_TYPES.include?(image.blob.content_type)
      errors.add(:image, :invalid_type)
    end

    if image.blob.byte_size > MAX_IMAGE_SIZE
      errors.add(:image, :too_large)
    end
  end
end
