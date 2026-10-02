class CreateAssignmentReminders < ActiveRecord::Migration[6.1]
  def change
    create_table :assignment_reminders do |t|
      t.references :assignment,
                   null: false,
                   foreign_key: true

      t.integer :reminder_type,
                   null: false

      t.datetime :scheduled_at,
                   null: false

      t.datetime :sent_at

      t.timestamps
    end

    add_index :assignment_reminders,
              [ :assignment_id, :reminder_type ],
              unique: true
  end
end
