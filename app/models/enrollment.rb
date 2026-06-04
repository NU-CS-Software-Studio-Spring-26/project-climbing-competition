class Enrollment < ApplicationRecord
  belongs_to :user
  belongs_to :competition

  validates :user_id, uniqueness: { scope: :competition_id }
  validate :competition_must_be_joinable, on: :create
  before_destroy :competition_must_be_leavable

  private

  def competition_must_be_joinable
    return if competition.blank? || competition.joinable?

    errors.add(:base, "This competition has ended and is no longer open for joining.")
  end

  def competition_must_be_leavable
    return if destroyed_by_association
    return if competition.blank? || competition.leavable?

    errors.add(:base, "This competition has ended. You can no longer leave it.")
    throw(:abort)
  end
end
