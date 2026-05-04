class Competition < ApplicationRecord
  LEVELS = %w[beginner intermediate advanced elite].freeze

  belongs_to :owner, class_name: "User", optional: true

  has_many :enrollments, dependent: :destroy
  has_many :users, through: :enrollments
  has_many :climbs, dependent: :destroy

  accepts_nested_attributes_for :climbs, allow_destroy: true, reject_if: :all_blank

  validates :name, :starts_at, :ends_at, :level, presence: true
  validates :level, inclusion: { in: LEVELS }
  validate :minimum_climbs

  private

  def minimum_climbs
    if climbs.reject(&:marked_for_destruction?).length < 2
      errors.add(:base, "Competition must have at least 2 climbs")
    end
  end
end
