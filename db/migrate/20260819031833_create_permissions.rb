class CreatePermissions < ActiveRecord::Migration[6.1]
  def change
    create_table :permissions do |t|
      t.string :resource
      t.string :action
      t.text :description

      t.timestamps
    end
  end
end
