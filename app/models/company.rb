class Company < ApplicationRecord
  has_many :users, dependent: :destroy
  has_many :assignments, dependent: :destroy

  validates :name, presence: true
  validates :address, presence: true
end
