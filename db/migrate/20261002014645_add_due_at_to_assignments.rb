class AddDueAtToAssignments < ActiveRecord::Migration[6.1]
  def change
    add_column :assignments, :due_at, :datetime, null: false
    add_index :assignments, :due_at
  end
end
