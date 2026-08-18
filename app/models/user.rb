class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  has_one_attached :avatar
  has_many :assignments, dependent: :destroy

  validates :username, presence: true, uniqueness: { case_sensitive: false }
  validates :first_name, :last_name, :department, presence: true
  validate :avatar_is_valid

  def full_name
    "#{first_name} #{last_name}".strip
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
