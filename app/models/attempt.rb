class Attempt < ApplicationRecord
  MAX_ATTEMPT_COUNT = 100

  belongs_to :user
  belongs_to :climb
  has_one_attached :submission_video

  delegate :competition, to: :climb

  validates :user_id, uniqueness: { scope: :climb_id }
  validate :attempt_count_must_be_integer_within_bounds

  def points_awarded
    return 0 if invalidated?

    competition.score_for_climb(
      sent:     true,
      flashed:  attempt_count == 1,
      attempts: attempt_count
    )
  end

  private

  def attempt_count_must_be_integer_within_bounds
    raw_value = attempt_count_before_type_cast.to_s
    return errors.add(:attempt_count, "is invalid") unless raw_value.match?(/\A\d+\z/)

    value = raw_value.to_i
    errors.add(:attempt_count, "is invalid") unless value.between?(1, MAX_ATTEMPT_COUNT)
  rescue ArgumentError, TypeError
    errors.add(:attempt_count, "is invalid")
  end
end
