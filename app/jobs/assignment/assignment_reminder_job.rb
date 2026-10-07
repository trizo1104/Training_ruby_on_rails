class Assignment::AssignmentReminderJob < ApplicationJob
  queue_as :reminders

  def perform(reminder_id)
    reminder = AssignmentReminder.find_by(id: reminder_id)

    return unless reminder
    return if reminder.sent_at?

    assignment = reminder.assignment

    AssignmentMailer
      .deadline_reminder(
        assignment: assignment,
        reminder: reminder
      )
      .deliver_now

    reminder.update!(
      sent_at: Time.current
    )
  end
end
