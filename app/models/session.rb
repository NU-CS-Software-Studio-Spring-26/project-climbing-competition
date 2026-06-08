class Session < ApplicationRecord
  IP_ADDRESS_MAX_LENGTH = 45
  USER_AGENT_MAX_LENGTH = 512

  belongs_to :user

  has_secure_token :token

  validates :ip_address, length: { maximum: IP_ADDRESS_MAX_LENGTH }, allow_blank: true
  validates :user_agent, length: { maximum: USER_AGENT_MAX_LENGTH }, allow_blank: true
end
