class Assignment < ApplicationRecord
  ALLOWED_IMAGE_TYPES = %w[image/jpeg image/png image/webp].freeze
  MAX_IMAGE_SIZE = 10.megabytes
  MAX_IMAGE_COUNT = 10

  belongs_to :user

  has_many_attached :images

  enum :status, { assigned: 0, finished: 1 }

  validates :content, presence: true
  validate :images_are_valid

  def sync_status_with_images!
    desired_status = images.attached? ? "finished" : "assigned"
    if new_record?
      self.status = desired_status
    elsif status != desired_status
      update!(status: desired_status)
    end
  end

  def validate_uploaded_images(files)
    files = Array(files).compact_blank
    errors.add(:images, "You can upload at most 10 images") if images.attachments.size + files.size > MAX_IMAGE_COUNT

    files.each do |file|
      unless file.respond_to?(:content_type) && file.respond_to?(:size)
        errors.add(:images, "must be JPEG, PNG, or WebP files")
        next
      end

      errors.add(:images, "must be JPEG, PNG, or WebP files") unless ALLOWED_IMAGE_TYPES.include?(file.content_type)
      errors.add(:images, "each image must be smaller than 10 MB") if file.size.to_i > MAX_IMAGE_SIZE
    end
  end

  private

  def images_are_valid
    return unless images.attached?

    if images.attachments.size > MAX_IMAGE_COUNT
      errors.add(:images, "You can upload at most 10 images")
    end

    images.each do |image|
      unless ALLOWED_IMAGE_TYPES.include?(image.blob.content_type)
        errors.add(:images, "must be JPEG, PNG, or WebP files")
      end

      errors.add(:images, "each image must be smaller than 10 MB") if image.blob.byte_size > MAX_IMAGE_SIZE
    end
  end
end
