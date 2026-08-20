class Company < ApplicationRecord
  has_many :users, dependent: :destroy

  validates :name, presence: true
  validates :address, presence: true
end
