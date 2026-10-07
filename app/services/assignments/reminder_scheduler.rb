class Assignments::ReminderScheduler
  def initialize(assignment)
    @assignment = assignment
  end

  def call
    schedule_reminder(:one_day_before, 24.hours)
    schedule_reminder(:one_hour_before, 1.hour)
  end

  def reschedule!
    cancel_existing_reminders!
    call
  end

  private

  attr_reader :assignment

  def schedule_reminder(type, offset)
    scheduled_at = assignment.due_at - offset

    return if scheduled_at <= Time.current

    reminder = assignment.assignment_reminders.create!(
      reminder_type: type,
      scheduled_at: scheduled_at
    )

    Assignment::AssignmentReminderJob
      .set(wait_until: scheduled_at)
      .perform_later(reminder.id)
  end

  def cancel_existing_reminders!
    assignment.assignment_reminders.destroy_all
  end
end
