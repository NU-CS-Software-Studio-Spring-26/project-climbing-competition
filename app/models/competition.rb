class Competition < ApplicationRecord
  belongs_to :owner, class_name: "User", optional: true

  has_many :enrollments, dependent: :destroy
  has_many :users, through: :enrollments

  validates :competition_start, :competition_end, presence: true
  validates :difficulty,
            numericality: { only_integer: true, greater_than_or_equal_to: 0, less_than_or_equal_to: 17 }
  validate :competition_end_on_or_after_start

  private
    def competition_end_on_or_after_start
      return if competition_start.blank? || competition_end.blank?
      return unless competition_end < competition_start

      errors.add(:competition_end, "must be on or after competition start")
    end
end
