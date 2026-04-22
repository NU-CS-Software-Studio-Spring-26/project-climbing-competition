class Enrollment < ApplicationRecord
  belongs_to :user
  belongs_to :competition

  validates :user_id, uniqueness: { scope: :competition_id }
end
