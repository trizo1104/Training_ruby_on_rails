class AssignmentReminder < ApplicationRecord
  belongs_to :assignment

  enum reminder_type: {
    one_day_before: 0,
    one_hour_before: 1
  }

  validates :scheduled_at, presence: true
end
