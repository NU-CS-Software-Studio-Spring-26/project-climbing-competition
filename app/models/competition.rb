class Competition < ApplicationRecord
  LEVELS = %w[beginner intermediate advanced elite].freeze
  LeaderboardEntry = Struct.new(:user, :points, :attempts_count, keyword_init: true)

  belongs_to :owner, class_name: "User", optional: true

  has_many :enrollments, dependent: :destroy
  has_many :users, through: :enrollments
  has_many :climbs, dependent: :destroy
  has_many :attempts, through: :climbs

  scope :upcoming, -> { where("starts_at > ?", Time.current) }
  scope :active, -> { where("starts_at <= ? AND ends_at > ?", Time.current, Time.current) }
  scope :past, -> { where("ends_at <= ?", Time.current) }

  accepts_nested_attributes_for :climbs, allow_destroy: true, reject_if: :all_blank

  validates :name, :starts_at, :ends_at, :level, presence: true
  validates :level, inclusion: { in: LEVELS }
  # ↓ ADD THESE THREE
  validates :send_points, presence: true, numericality: { only_integer: true, greater_than: 0 }
  validates :flash_points, presence: true, numericality: { only_integer: true, greater_than: 0 }
  validates :attempt_deduction, presence: true, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
  validate :minimum_climbs

  # ↓ REPLACE the existing points_for(user) with this
  def points_for(user)
    return 0 if user.nil?

    attempts.where(user: user).to_a.sum(&:points_awarded)
  end

  # ↓ ADD this new method for scoring a single climb
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

  private

  def minimum_climbs
    if climbs.reject(&:marked_for_destruction?).length < 2
      errors.add(:base, "Competition must have at least 2 climbs")
    end
  end
end
