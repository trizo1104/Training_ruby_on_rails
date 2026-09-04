class Assignment < ApplicationRecord
  # ALLOWED_IMAGE_TYPES = %w[image/jpeg image/png image/webp].freeze
  # MAX_IMAGE_SIZE = 10.megabytes
  MAX_IMAGE_COUNT = 10

  belongs_to :user

  has_many :assignment_images,
        -> { order(position: :asc) },
        dependent: :destroy # when assignment is deleted, all associated assignment_images also will be deleted

  enum :status, { assigned: 0, finished: 1 }

  validates :content, presence: true
  # validate :images_are_valid

  def sync_status_with_images!
    desired_status = assignment_images.exists? ? "finished" : "assigned"
    if new_record?
      self.status = desired_status
    elsif status != desired_status
      update!(status: desired_status)
    end
  end

  def validate_uploaded_images(files)
    files = Array(files).compact_blank

    if assignment_images.count + files.size > MAX_IMAGE_COUNT
      errors.add(:images, :too_many)
    end
    # errors.add(:images, :too_many) if images.attachments.size + files.size > MAX_IMAGE_COUNT

    # files.each do |file|
    #   unless file.respond_to?(:content_type) && file.respond_to?(:size)
    #     errors.add(:images, :invalid_type)
    #     next
    #   end

    #   errors.add(:images, :invalid_type) unless ALLOWED_IMAGE_TYPES.include?(file.content_type)
    #   errors.add(:images, :too_large) if file.size.to_i > MAX_IMAGE_SIZE
    # end
  end

  # private

  # def images_are_valid
  #   return unless images.attached?

  #   if images.attachments.size > MAX_IMAGE_COUNT
  #     errors.add(:images, :too_many)
  #   end

  #   images.each do |image|
  #     unless ALLOWED_IMAGE_TYPES.include?(image.blob.content_type)
  #       errors.add(:images, :invalid_type)
  #     end

  #     errors.add(:images, :too_large) if image.blob.byte_size > MAX_IMAGE_SIZE
  #   end
  # end
end
