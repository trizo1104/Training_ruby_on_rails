class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  has_one_attached :avatar
  has_many :assignments, dependent: :destroy

  belongs_to :company, optional: true

  belongs_to :manager,
            class_name: "User",
            optional: true

  has_many :employees,
          class_name: "User",
          foreign_key: :manager_id,
          dependent: :nullify

  has_many :user_roles, dependent: :destroy
  has_many :roles, through: :user_roles
  has_many :permissions, through: :roles

  validates :username, presence: true, uniqueness: { case_sensitive: false }
  validates :first_name, :last_name, :department, presence: true
  validate :avatar_is_valid

  def full_name
    "#{first_name} #{last_name}".strip
  end

  def has_permission?(resource, action)
    permissions.exists?(
      resource: resource,
      action: action
      )
  end

  private

  def avatar_is_valid
    return unless avatar.attached?

    unless %w[image/jpeg image/png image/webp].include?(avatar.blob.content_type)
      errors.add(:avatar, :invalid_type)
    end

    errors.add(:avatar, :too_large) if avatar.blob.byte_size > 5.megabytes
  end
end
