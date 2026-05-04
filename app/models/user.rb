class User < ApplicationRecord
  USERNAME_FORMAT = /\A[a-zA-Z0-9_.-]+\z/

  has_many :enrollments, dependent: :destroy
  has_many :competitions, through: :enrollments
  has_many :attempts, dependent: :destroy
  has_many :owned_competitions, class_name: "Competition", foreign_key: "owner_id", dependent: :nullify, inverse_of: :owner
  has_many :sessions, dependent: :destroy

  has_secure_password

  before_validation :sanitize_profile_fields

  normalizes :email_address, with: ->(value) { value.strip.downcase }
  normalizes :name, with: ->(value) { value&.strip&.squish }
  normalizes :username, with: ->(value) { value.strip }

  validates :name, :username, :email_address, presence: true
  validates :name, length: { maximum: 80 }
  validates :username, uniqueness: { case_sensitive: false }
  validates :username, length: { maximum: 30 }, format: { with: USERNAME_FORMAT }
  validates :email_address, uniqueness: { case_sensitive: false }
  validates :email_address, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :password, length: { minimum: 8 }, allow_blank: true
  validates :bio, length: { maximum: 500 }, allow_blank: true

  private
    def sanitize_profile_fields
      self.name = sanitize_text(name)
      self.username = sanitize_text(username)
      self.bio = sanitize_text(bio)
    end

    def sanitize_text(value)
      return if value.nil?

      ActionController::Base.helpers.strip_tags(value.to_s).squish
    end
end
