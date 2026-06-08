ENV["RAILS_ENV"] ||= "test"
require_relative "../config/environment"
require "rails/test_help"

module ActiveSupport
  class TestCase
    # Run tests in parallel with specified workers
    # Process-based workers get separate test DBs; thread-based workers share SQLite
    # and cause nested transaction / rollback errors with transactional fixtures.
    # fork() is unavailable on Windows, so parallelize only on Unix-like platforms.
    parallelize(workers: :number_of_processors) unless Gem.win_platform?

    # Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical order.
    fixtures :all

    # Add more helper methods to be used by all tests here...
    def mock_omniauth(provider, **attributes)
      OmniAuth.config.test_mode = true
      OmniAuth.config.mock_auth[provider.to_sym] = OmniAuth::AuthHash.new(
        provider: provider.to_s,
        uid: attributes[:uid],
        info: {
          email: attributes[:email],
          name: attributes[:name],
          nickname: attributes[:nickname]
        }.compact
      )
    end

    teardown do
      OmniAuth.config.mock_auth.clear
      OmniAuth.config.test_mode = false
    end
  end
end
