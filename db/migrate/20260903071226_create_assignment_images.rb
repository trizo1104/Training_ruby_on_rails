class CreateAssignmentImages < ActiveRecord::Migration[8.1]
  def change
    create_table :assignment_images do |t|
      t.references :assignment, null: false, foreign_key: true
      t.integer :position

      t.timestamps
    end

    add_index :assignment_images, # make sure each position is unique for a given assigment
          [ :assignment_id, :position ],
          unique: true
  end
end
