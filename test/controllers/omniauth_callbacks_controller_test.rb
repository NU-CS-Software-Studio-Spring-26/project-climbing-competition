require "test_helper"

class OmniauthCallbacksControllerTest < ActionDispatch::IntegrationTest
  test "creates a new user and signs in via google" do
    mock_omniauth(:google_oauth2, uid: "new-google-uid", email: "new.oauth@example.com", name: "New OAuth")

    assert_difference [ "User.count", "Session.count" ], 1 do
      get "/auth/google_oauth2/callback"
    end

    user = User.find_by!(email_address: "new.oauth@example.com")
    assert_equal "new-google-uid", user.google_uid
    assert user.password_digest.present?
    assert_redirected_to competitions_path
    follow_redirect!
    assert_response :success
  end

  test "signs in an existing user by google uid" do
    user = users(:one)
    user.update!(google_uid: "google-uid-1")

    mock_omniauth(:google_oauth2, uid: user.google_uid, email: user.email_address)

    assert_no_difference "User.count" do
      assert_difference "Session.count", 1 do
        get "/auth/google_oauth2/callback"
      end
    end

    assert_redirected_to competitions_path
  end

  test "auto-links oauth to an existing password account by email" do
    user = users(:two)

    mock_omniauth(:google_oauth2, uid: "google-uid-link", email: user.email_address, name: user.name)

    assert_no_difference "User.count" do
      assert_difference "Session.count", 1 do
        get "/auth/google_oauth2/callback"
      end
    end

    assert_equal "google-uid-link", user.reload.google_uid
    assert_redirected_to competitions_path
  end

  test "redirects with alert when email is missing" do
    mock_omniauth(:google_oauth2, uid: "no-email-uid", email: nil)

    assert_no_difference [ "User.count", "Session.count" ] do
      get "/auth/google_oauth2/callback"
    end

    assert_redirected_to new_session_path
    assert_equal "Google sign-in failed. Please try again.", flash[:alert]
  end

  test "failure redirects to sign in" do
    get "/auth/failure", params: { message: "access_denied" }

    assert_redirected_to new_session_path
    assert_equal "Google sign-in failed. Please try again.", flash[:alert]
  end
end
