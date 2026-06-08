class User < ApplicationRecord
  include ProfanityFilterable

  USERNAME_FORMAT = /\A[a-zA-Z0-9_.-]+\z/
  EMAIL_FORMAT = /\A[^\s@]+@(?:[^\s@]+\.)+[^\s@]{2,}\z/
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
  has_many :active_follows, class_name: "Follow", foreign_key: :follower_id, dependent: :destroy, inverse_of: :follower
  has_many :passive_follows, class_name: "Follow", foreign_key: :followed_id, dependent: :destroy, inverse_of: :followed
  has_many :following, through: :active_follows, source: :followed
  has_many :followers, through: :passive_follows, source: :follower

  has_secure_password

  generates_token_for :password_reset, expires_in: 15.minutes do
    password_salt&.last(10)
  end

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
  validates :email_address, format: { with: EMAIL_FORMAT }
  validates :google_uid, uniqueness: true, allow_blank: true
  validates :password, length: { minimum: PASSWORD_MIN_LENGTH, maximum: PASSWORD_MAX_LENGTH }, allow_blank: true
  validates :password, confirmation: true, if: -> { password.present? }
  validates :bio, length: { maximum: BIO_MAX_LENGTH }, allow_blank: true

  validate :name_has_no_control_characters
  validate :name_contains_letter
  validate :bio_has_no_control_characters, if: -> { bio.present? }

  filters_profanity_in :name, :username
  filters_profanity_in :bio, allow_blank: true

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

  public
    def self.username_taken?(username)
      where("lower(username) = ?", username.to_s.downcase).exists?
    end

    def participated_competitions_count
      competitions.count
    end

    def created_competitions_count
      owned_competitions.count
    end

    def current_competitions
      competitions.merge(Competition.upcoming.or(Competition.active)).order(:starts_at)
    end

    def average_placement
      placements = competitions.merge(Competition.past).filter_map { |competition| competition.placement_for(self) }
      return nil if placements.empty?

      (placements.sum.to_f / placements.size).round(1)
    end

    def placement_in(competition)
      competition.placement_for(self)
    end

    def following?(other_user)
      return false if other_user.blank? || other_user == self

      active_follows.exists?(followed_id: other_user.id)
    end

    def password_resettable?
      google_uid.blank? && password_digest.present?
    end
end
