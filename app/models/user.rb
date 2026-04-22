class User < ApplicationRecord
  has_many :enrollments, dependent: :destroy
  has_many :competitions, through: :enrollments
  has_many :owned_competitions, class_name: "Competition", foreign_key: "owner_id", dependent: :nullify, inverse_of: :owner
end
