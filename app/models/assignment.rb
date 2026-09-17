class Assignment < ApplicationRecord
  MAX_IMAGE_COUNT = 10

  belongs_to :user, optional: true
  belongs_to :company

  has_many :assignment_images,
        -> { order(position: :asc) },
        dependent: :destroy # when assignment is deleted, all associated assignment_images also will be deleted

  enum :status, { assigned: 0, finished: 1 }

  validates :content, presence: true

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
  end
end
