class CreateAssignments < ActiveRecord::Migration[8.1]
  def change
    create_table :assignments do |t|
      t.references :user,
                   null: true,
                   foreign_key: { on_delete: nullify }

      t.text :content, null: false

      t.integer :status,
                null: false,
                default: 0

      t.timestamps
    end

    add_index :assignments, [ :user_id, :created_at ]
  end
end
