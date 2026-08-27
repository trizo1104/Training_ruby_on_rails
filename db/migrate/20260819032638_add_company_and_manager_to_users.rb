class AddCompanyAndManagerToUsers < ActiveRecord::Migration[8.1]
  def change
    add_reference :users, :company, foreign_key: true

    add_reference :users, :manager,
                  foreign_key: { to_table: :users }
  end
end
