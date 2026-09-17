class AddCompanyToAssignments < ActiveRecord::Migration[8.1]
  def change
    add_reference :assignments, :company, null: false, foreign_key: true
  end
end
