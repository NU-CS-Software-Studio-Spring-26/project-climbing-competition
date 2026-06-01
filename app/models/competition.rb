class Competition < ApplicationRecord
  V_GRADES = (0..16).to_a
  LEVEL_GRADE_RANGES = {
    "beginner" => [ 0, 3 ],
    "intermediate" => [ 4, 6 ],
    "advanced" => [ 7, 9 ],
    "elite" => [ 10, 16 ]
  }.freeze
  LEVELS = LEVEL_GRADE_RANGES.keys.freeze
  LeaderboardEntry = Struct.new(:user, :points, :attempts_count, keyword_init: true)

  belongs_to :owner, class_name: "User", optional: true

  has_many :enrollments, dependent: :destroy
  has_many :users, through: :enrollments
  has_many :climbs, dependent: :destroy
  has_many :attempts, through: :climbs

  scope :upcoming, -> { where("starts_at > ?", Time.current) }
  scope :active, -> { where("starts_at <= ? AND ends_at > ?", Time.current, Time.current) }
  scope :past, -> { where("ends_at <= ?", Time.current) }
  scope :within_grade_range, ->(min_grade, max_grade) {
    grade_int_sql = "CAST(REPLACE(climbs.grading, 'V', '') AS INTEGER)"
    climb_bounds = joins(:climbs)
      .where.not(climbs: { grading: [ nil, "" ] })
      .group(:id)
      .having("MIN(#{grade_int_sql}) >= ? AND MAX(#{grade_int_sql}) <= ?", min_grade, max_grade)
      .select(:id)

    where(id: climb_bounds)
  }

  scope :ordered_by_status, -> {
    now = Time.current
    order(
      Arel.sql(sanitize_sql_array([
        "CASE WHEN (starts_at IS NULL OR starts_at > ?) THEN 1 WHEN (ends_at IS NULL OR ends_at <= ?) THEN 2 ELSE 0 END",
        now, now
      ])),
      starts_at: :asc
    )
  }

  def status
    now = Time.current
    return :upcoming if starts_at.nil? || starts_at > now
    return :past    if ends_at.nil?   || ends_at <= now
    :active
  end

  def past?
    status == :past
  end

  def joinable?
    !past?
  end

  def leavable?
    !past?
  end

  def climb_grade_integers
    climbs.reject(&:marked_for_destruction?).filter_map { |climb| grading_to_int(climb.grading) }
  end

  def climb_grade_range_label
    grades = climb_grade_integers
    return nil if grades.empty?

    min = grades.min
    max = grades.max
    return format_v_grade(min) if min == max
    return "V10+" if min >= 10

    "#{format_v_grade(min)}–#{format_v_grade(max)}"
  end

  # Card color tier from peak grade: V0–3, V4–6, V7–9, V10+
  def grade_range_tier
    peak = climb_grade_integers.max || v_grade_max
    case peak
    when 0..3 then :v0_3
    when 4..6 then :v4_6
    when 7..9 then :v7_9
    else :v10_plus
    end
  end

  accepts_nested_attributes_for :climbs, allow_destroy: true, reject_if: :all_blank

  before_validation :sanitize_text_fields
  before_validation :derive_level_and_grades_from_climbs

  validates :name, :starts_at, :ends_at, presence: true
  validates :name, length: { maximum: 100 }
  validates :description, length: { maximum: 2000 }, allow_blank: true
  validates :send_points, presence: true, numericality: { only_integer: true, greater_than: 0 }
  validates :flash_points, presence: true, numericality: { only_integer: true, greater_than: 0 }
  validates :attempt_deduction, presence: true, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
  validates :v_grade_min, :v_grade_max, presence: true,
            numericality: { only_integer: true, greater_than_or_equal_to: 0, less_than_or_equal_to: 16 }
  validate :minimum_climbs
  validate :climbs_have_grades
  validate :grade_range_is_valid
  validate :ends_at_after_starts_at

  def points_for(user)
    return 0 if user.nil?
    attempts.where(user: user).to_a.sum(&:points_awarded)
  end

  def score_for_climb(sent:, flashed:, attempts:)
    return 0 unless sent
    base      = flashed ? flash_points : send_points
    deduction = flashed ? 0 : (attempts - 1) * attempt_deduction
    [ base - deduction, 0 ].max
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
    end.sort_by { |entry| [ -entry.points, entry.attempts_count, entry.user.username.downcase ] }
  end

  def placement_for(user)
    return nil if user.nil?

    leaderboard_entries.each_with_index do |entry, index|
      return index + 1 if entry.user.id == user.id
    end

    nil
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

  def ends_at_after_starts_at
    return if starts_at.blank? || ends_at.blank?
    return if ends_at > starts_at

    errors.add(:ends_at, "must be after the start date and time")
  end

  def derive_level_and_grades_from_climbs
    grades = climb_grade_integers
    return if grades.empty?

    self.v_grade_min = grades.min
    self.v_grade_max = grades.max
    self.level = level_for_peak_grade(v_grade_max)
  end

  def climbs_have_grades
    active_climbs = climbs.reject(&:marked_for_destruction?)
    return if active_climbs.empty?

    if active_climbs.any? { |climb| climb.grading.blank? }
      errors.add(:base, "Every climb must have a V-grade so competition difficulty can be set automatically")
    end
  end

  def grading_to_int(grading)
    return if grading.blank?

    grading.to_s.delete_prefix("V").to_i
  end

  def format_v_grade(grade)
    grade >= 10 ? "V10+" : "V#{grade}"
  end

  def level_for_peak_grade(peak)
    case peak
    when 0..3 then "beginner"
    when 4..6 then "intermediate"
    when 7..9 then "advanced"
    else "elite"
    end
  end
end
