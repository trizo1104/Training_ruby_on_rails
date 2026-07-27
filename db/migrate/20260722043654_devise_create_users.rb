class DeviseCreateUsers < ActiveRecord::Migration[8.1]
  def change
    create_table :users do |t|
      # Devise authentication fields
      t.string :email, null: false, default: ""
      t.string :encrypted_password, null: false, default: ""

      # Application profile fields
      t.string :username, null: false
      t.string :first_name, null: false
      t.string :last_name, null: false
      t.string :department, null: false

      # Devise recoverable
      t.string :reset_password_token
      t.datetime :reset_password_sent_at

      # Devise rememberable
      t.datetime :remember_created_at

      t.timestamps
    end

    add_index :users, :email, unique: true
    add_index :users, :username, unique: true
    add_index :users, :reset_password_token, unique: true
  end
end
