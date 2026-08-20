class Permission < ApplicationRecord
  has_many :role_permissions, dependent: :destroy
  has_many :roles, through: :role_permissions

  validates :resource, presence: true
  validates :action, presence: true

  validates :action,
            uniqueness: {
              scope: :resource,
              case_sensitive: false
            }
end
