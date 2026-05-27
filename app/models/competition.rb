class Competition < ApplicationRecord
  V_GRADES = (0..16).to_a
  LeaderboardEntry = Struct.new(:user, :points, :attempts_count, keyword_init: true)

  belongs_to :owner, class_name: "User", optional: true

  has_many :enrollments, dependent: :destroy
  has_many :users, through: :enrollments
  has_many :climbs, dependent: :destroy
  has_many :attempts, through: :climbs

  scope :upcoming, -> { where("starts_at > ?", Time.current) }
  scope :active, -> { where("starts_at <= ? AND ends_at > ?", Time.current, Time.current) }
  scope :past, -> { where("ends_at <= ?", Time.current) }

  def status
    now = Time.current
    return :upcoming if starts_at.nil? || starts_at > now
    return :past    if ends_at.nil?   || ends_at <= now
    :active
  end

  # Card color tier from peak grade: V0–3, V4–6, V7–9, V10+
  def grade_range_tier
    case v_grade_max
    when 0..3 then :v0_3
    when 4..6 then :v4_6
    when 7..9 then :v7_9
    else :v10_plus
    end
  end

  accepts_nested_attributes_for :climbs, allow_destroy: true, reject_if: :all_blank

  before_validation :sanitize_text_fields

  validates :name, :starts_at, :ends_at, presence: true
  validates :name, length: { maximum: 100 }
  validates :description, length: { maximum: 2000 }, allow_blank: true
  validates :send_points, presence: true, numericality: { only_integer: true, greater_than: 0 }
  validates :flash_points, presence: true, numericality: { only_integer: true, greater_than: 0 }
  validates :attempt_deduction, presence: true, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
  validates :v_grade_min, :v_grade_max, presence: true,
            numericality: { only_integer: true, greater_than_or_equal_to: 0, less_than_or_equal_to: 16 }
  validate :minimum_climbs
  validate :grade_range_is_valid

  def points_for(user)
    return 0 if user.nil?
    attempts.where(user: user).to_a.sum(&:points_awarded)
  end

  def score_for_climb(sent:, flashed:, attempts:)
    return 0 unless sent
    base      = flashed ? flash_points : send_points
    deduction = flashed ? 0 : (attempts - 1) * attempt_deduction
    [base - deduction, 0].max
  end

  def leaderboard_entries
    attempts_by_user_id = attempts.to_a.group_by(&:user_id)

    users.map do |user|
      user_attempts = attempts_by_user_id.fetch(user.id, [])
      LeaderboardEntry.new(
        user: user,
        points: user_attempts.sum(&:points_awarded),
        attempts_count: user_attempts.sum { |attempt| attempt.attempt_count.to_i }
      )
    end.sort_by { |entry| [-entry.points, entry.attempts_count, entry.user.username.downcase] }
  end

  private

  def sanitize_text_fields
    self.name = strip_tags(name)&.squish if name.present?
    self.description = strip_tags(description)&.squish if description.present?
  end

  def strip_tags(value)
    ActionController::Base.helpers.strip_tags(value.to_s)
  end

  def minimum_climbs
    if climbs.reject(&:marked_for_destruction?).length < 2
      errors.add(:base, "Competition must have at least 2 climbs")
    end
  end

  def grade_range_is_valid
    return unless v_grade_min && v_grade_max
    errors.add(:v_grade_max, "must be >= min grade") if v_grade_max < v_grade_min
  end
end
