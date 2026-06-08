class Climb < ApplicationRecord
  include ProfanityFilterable

  GRADES = (0..16).map { |n| "V#{n}" }.freeze
  URL_MAX_LENGTH = 2000
  ALLOWED_URL_HOSTS = %w[www.boardsesh.com app.kiltergrips.com].freeze
  HOLD_COLORS = %w[purple green blue yellow].freeze
  HOLD_ID_PATTERN = /\Ar\d+c\d+\z/
  MAX_HOLD_ASSIGNMENTS = 1200

  belongs_to :competition
  has_many :attempts, dependent: :destroy

  validates :name, :url, presence: true
  validates :name, length: { maximum: 100 }
  validates :url, length: { maximum: URL_MAX_LENGTH },
                  format: { with: URI::DEFAULT_PARSER.make_regexp(%w[http https]), message: "must be a valid URL" }
  validates :grading, presence: true, inclusion: { in: GRADES, message: "must be a V-grade (V0–V16)" }
  validate :hold_assignments_are_valid
  validate :url_must_be_from_allowed_hosts

  filters_profanity_in :name

  before_validation :sanitize_fields
  before_validation :sanitize_hold_assignments

  def url_must_be_from_allowed_hosts
    return if url.blank?

    host = URI.parse(url).host&.downcase
    return if host.present? && ALLOWED_URL_HOSTS.include?(host)

    errors.add(:url, "must be a link from www.boardsesh.com or app.kiltergrips.com")
  rescue URI::InvalidURIError
    # The URL format validation will provide the error message.
  end

  def visual?
    hold_assignments.is_a?(Hash) && hold_assignments.any?
  end

  private

  def sanitize_fields
    self.name = ActionController::Base.helpers.strip_tags(name.to_s).squish if name.present?
    self.url = url.to_s.strip if url.present?
    self.grading = grading.to_s.strip.upcase if grading.present?
  end

  def sanitize_hold_assignments
    parsed_assignments =
      case hold_assignments
      when String
        JSON.parse(hold_assignments)
      when Hash
        hold_assignments
      else
        {}
      end

    sanitized = {}
    parsed_assignments.each do |hold_id, color|
      normalized_hold_id = hold_id.to_s
      normalized_color = color.to_s.downcase
      next unless normalized_hold_id.match?(HOLD_ID_PATTERN)
      next unless HOLD_COLORS.include?(normalized_color)

      sanitized[normalized_hold_id] = normalized_color
    end

    self.hold_assignments = sanitized
  rescue JSON::ParserError
    self.hold_assignments = {}
  end

  def hold_assignments_are_valid
    assignments = hold_assignments.is_a?(Hash) ? hold_assignments : {}

    if assignments.size > MAX_HOLD_ASSIGNMENTS
      errors.add(:hold_assignments, "has too many selected holds")
    end

    assignments.each do |hold_id, color|
      unless hold_id.to_s.match?(HOLD_ID_PATTERN)
        errors.add(:hold_assignments, "contains an invalid hold")
        break
      end
      unless HOLD_COLORS.include?(color.to_s.downcase)
        errors.add(:hold_assignments, "contains an invalid color")
        break
      end
    end
  end
end
