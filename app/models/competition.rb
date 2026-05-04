class Competition < ApplicationRecord
  LEVELS = %w[beginner intermediate advanced elite].freeze
  LeaderboardEntry = Struct.new(:user, :points, :attempts_count, keyword_init: true)

  belongs_to :owner, class_name: "User", optional: true

  has_many :enrollments, dependent: :destroy
  has_many :users, through: :enrollments
  has_many :climbs, dependent: :destroy
  has_many :attempts, through: :climbs

  accepts_nested_attributes_for :climbs, allow_destroy: true, reject_if: :all_blank

  validates :name, :starts_at, :ends_at, :level, presence: true
  validates :level, inclusion: { in: LEVELS }
  validate :minimum_climbs

  def points_for(user)
    return 0 if user.nil?

    attempts.where(user: user).to_a.sum(&:points_awarded)
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
