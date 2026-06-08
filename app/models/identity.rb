class Identity < ApplicationRecord
  PROVIDERS = %w[google_oauth2 github apple].freeze

  belongs_to :user

  validates :provider, presence: true, inclusion: { in: PROVIDERS }
  validates :uid, presence: true, uniqueness: { scope: :provider }
end
