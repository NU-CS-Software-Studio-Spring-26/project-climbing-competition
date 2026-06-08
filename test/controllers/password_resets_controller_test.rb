require "test_helper"

class PasswordResetsControllerTest < ActionDispatch::IntegrationTest
  include ActiveJob::TestHelper

  setup do
    @user = users(:one)
  end

  test "should get new" do
    get new_password_reset_url
    assert_response :success
    assert_select "input[name='password_reset[email_address]']"
  end

  test "should enqueue reset email for password account" do
    assert_enqueued_emails 1 do
      post password_resets_url, params: { password_reset: { email_address: @user.email_address } }
    end

    assert_redirected_to new_session_url
    assert_equal "If that email is registered with a password account, you will receive reset instructions shortly.",
      flash[:notice]
  end

  test "should not enqueue reset email for google-only account" do
    google_user = users(:google_only)

    assert_no_enqueued_emails do
      post password_resets_url, params: { password_reset: { email_address: google_user.email_address } }
    end

    assert_redirected_to new_session_url
  end

  test "should not reveal unknown email" do
    assert_no_enqueued_emails do
      post password_resets_url, params: { password_reset: { email_address: "missing@example.com" } }
    end

    assert_redirected_to new_session_url
    assert_equal "If that email is registered with a password account, you will receive reset instructions shortly.",
      flash[:notice]
  end

  test "should get edit with valid token" do
    token = @user.generate_token_for(:password_reset)

    get edit_password_reset_url(token)
    assert_response :success
    assert_select "input[name='password_reset[password]']"
  end

  test "should reject invalid token" do
    get edit_password_reset_url("invalid-token")
    assert_redirected_to new_password_reset_url
    assert_equal "Password reset link is invalid or has expired.", flash[:alert]
  end

  test "should update password with valid token" do
    token = @user.generate_token_for(:password_reset)
    post session_url, params: { session: { email_address: @user.email_address, password: "password123" } }
    assert @user.sessions.exists?

    patch password_reset_url(token), params: {
      password_reset: { password: "newpassword1", password_confirmation: "newpassword1" }
    }

    assert_redirected_to new_session_url
    assert_equal "Your password has been reset. Sign in with your new password.", flash[:notice]
    assert @user.reload.authenticate("newpassword1")
    assert_not @user.sessions.exists?
  end

  test "should reject mismatched passwords" do
    token = @user.generate_token_for(:password_reset)

    patch password_reset_url(token), params: {
      password_reset: { password: "newpassword1", password_confirmation: "different1" }
    }

    assert_response :unprocessable_entity
    assert @user.reload.authenticate("password123")
  end
end
