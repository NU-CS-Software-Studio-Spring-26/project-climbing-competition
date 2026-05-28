require "test_helper"

class OmniauthCallbacksControllerTest < ActionDispatch::IntegrationTest
  test "creates a new user and signs in via google" do
    mock_omniauth(:google_oauth2, uid: "new-google-uid", email: "new.oauth@example.com", name: "New OAuth")

    assert_difference [ "User.count", "Identity.count", "Session.count" ], 1 do
      get "/auth/google_oauth2/callback"
    end

    user = User.find_by!(email_address: "new.oauth@example.com")
    assert_nil user.password_digest
    assert user.identities.exists?(provider: "google_oauth2", uid: "new-google-uid")
    assert_redirected_to competitions_path
    follow_redirect!
    assert_response :success
  end

  test "signs in an existing identity" do
    identity = identities(:google_identity)

    mock_omniauth(:google_oauth2, uid: identity.uid, email: identity.user.email_address)

    assert_no_difference "User.count" do
      assert_difference "Session.count", 1 do
        get "/auth/google_oauth2/callback"
      end
    end

    assert_redirected_to competitions_path
  end

  test "auto-links oauth to an existing password account by email" do
    user = users(:two)

    mock_omniauth(:github, uid: "github-uid-link", email: user.email_address, nickname: "ben")

    assert_no_difference "User.count" do
      assert_difference "Identity.count", 1 do
        get "/auth/github/callback"
      end
    end

    assert user.identities.exists?(provider: "github", uid: "github-uid-link")
    assert_redirected_to competitions_path
  end

  test "redirects with alert when email is missing" do
    mock_omniauth(:google_oauth2, uid: "no-email-uid", email: nil)

    assert_no_difference [ "User.count", "Identity.count" ] do
      get "/auth/google_oauth2/callback"
    end

    assert_redirected_to new_session_path
    assert_equal "We could not get an email address from your account. Try another sign-in method or use email sign-up.", flash[:alert]
  end

  test "failure redirects to sign in" do
    get "/auth/failure", params: { message: "access_denied" }

    assert_redirected_to new_session_path
    assert_equal "access_denied", flash[:alert]
  end
end
