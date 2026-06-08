require "test_helper"
require "omniauth"

class SessionsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:one)
    OmniAuth.config.test_mode = true
    OmniAuth.config.mock_auth[:google_oauth2] = OmniAuth::AuthHash.new(
      provider: "google_oauth2",
      uid: "google-uid-123",
      info: {
        email: @user.email_address,
        name: @user.name
      }
    )
  end

  teardown do
    OmniAuth.config.mock_auth[:google_oauth2] = nil
    OmniAuth.config.mock_auth[:default] = nil
    OmniAuth.config.test_mode = false
  end

  test "should get new" do
    get new_session_url
    assert_response :success
    assert_select "input[name='session[email_address]']"
    assert_select "input[name='session[password]']"
  end

  test "should sign in user" do
    post session_url, params: { session: { email_address: @user.email_address, password: "password123" } }

    assert_redirected_to competitions_url
  end

  test "should reject invalid credentials" do
    post session_url, params: { session: { email_address: @user.email_address, password: "wrong-password" } }

    assert_response :unprocessable_entity
  end

  test "should sign out user" do
    post session_url, params: { session: { email_address: @user.email_address, password: "password123" } }
    delete session_url

    assert_redirected_to root_url
  end

  test "should sign in with google and link existing user" do
    post "/auth/google_oauth2/callback"

    assert_redirected_to competitions_url
    assert_equal "google-uid-123", @user.reload.google_uid
  end

  test "should create user from google callback when not found" do
    OmniAuth.config.mock_auth[:google_oauth2] = OmniAuth::AuthHash.new(
      provider: "google_oauth2",
      uid: "google-uid-new",
      info: {
        email: "newgoogle@example.com",
        name: "New Google User"
      }
    )

    assert_difference("User.count", 1) do
      post "/auth/google_oauth2/callback"
    end

    assert_redirected_to competitions_url
    assert_equal "google-uid-new", User.find_by(email_address: "newgoogle@example.com")&.google_uid
  end

  test "should redirect on google auth failure" do
    get "/auth/failure", params: { message: "invalid_credentials", strategy: "google_oauth2" }

    assert_redirected_to new_session_url
  end
end
