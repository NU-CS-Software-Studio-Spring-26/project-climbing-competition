class Attempt < ApplicationRecord
  belongs_to :user
  belongs_to :climb

  delegate :competition, to: :climb

  validates :user_id, uniqueness: { scope: :climb_id }
  validate :attempt_count_must_be_integer_within_bounds

  def points_awarded
    return 0 unless completed?

    10 + (attempt_count == 1 ? 5 : 0)
  end

  private

  def attempt_count_must_be_integer_within_bounds
    raw_value = attempt_count_before_type_cast
    return errors.add(:attempt_count, "is invalid") unless raw_value.to_s.match?(/\A\d+\z/)

    value = raw_value.to_i
    errors.add(:attempt_count, "is invalid") unless value.between?(1, 100)
  rescue ArgumentError, TypeError
    errors.add(:attempt_count, "is invalid")
  end
end
