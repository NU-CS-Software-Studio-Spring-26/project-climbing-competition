# frozen_string_literal: true

module OmniauthHelpers
  def mock_omniauth(provider, uid:, email:, name: nil, nickname: nil)
    OmniAuth.config.mock_auth[provider.to_sym] = OmniAuth::AuthHash.new(
      provider: provider.to_s,
      uid: uid.to_s,
      info: OmniAuth::AuthHash::InfoHash.new(
        email: email,
        name: name || "OAuth User",
        nickname: nickname
      ),
      credentials: OmniAuth::AuthHash.new(token: "mock-token")
    )
  end

  def clear_omniauth_mock
    OmniAuth.config.mock_auth.clear
  end
end
