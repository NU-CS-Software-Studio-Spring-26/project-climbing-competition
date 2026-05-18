class User < ApplicationRecord
  USERNAME_FORMAT = /\A[a-zA-Z0-9_.-]+\z/
  CONTROL_CHAR_PATTERN = /[\x00-\x08\x0B\x0C\x0E-\x1F\x7F]/
  UNICODE_LETTER_PATTERN = /\p{L}/

  NAME_MAX_LENGTH = 80
  USERNAME_MAX_LENGTH = 30
  EMAIL_MAX_LENGTH = 254
  BIO_MAX_LENGTH = 500
  PASSWORD_MIN_LENGTH = 8
  PASSWORD_MAX_LENGTH = 72

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
  validates :name, length: { minimum: 1, maximum: NAME_MAX_LENGTH }
  validates :username, uniqueness: { case_sensitive: false }
  validates :username, length: { minimum: 1, maximum: USERNAME_MAX_LENGTH }, format: { with: USERNAME_FORMAT }
  validates :email_address, uniqueness: { case_sensitive: false }
  validates :email_address, length: { maximum: EMAIL_MAX_LENGTH }
  validates :email_address, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :password, length: { minimum: PASSWORD_MIN_LENGTH, maximum: PASSWORD_MAX_LENGTH }, allow_blank: true
  validates :password, confirmation: true, if: -> { password.present? }
  validates :bio, length: { maximum: BIO_MAX_LENGTH }, allow_blank: true

  validate :name_has_no_control_characters
  validate :name_contains_letter
  validate :bio_has_no_control_characters, if: -> { bio.present? }

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

    def name_has_no_control_characters
      reject_control_characters(:name, name)
    end

    def bio_has_no_control_characters
      reject_control_characters(:bio, bio)
    end

    def reject_control_characters(attribute, value)
      return if value.blank?
      return unless value.match?(CONTROL_CHAR_PATTERN)

      errors.add(attribute, "contains invalid characters")
    end

    def name_contains_letter
      return if name.blank?
      return if name.match?(UNICODE_LETTER_PATTERN)

      errors.add(:name, "must include at least one letter")
    end
end
