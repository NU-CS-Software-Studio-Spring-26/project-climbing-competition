require "test_helper"

class SessionsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:one)
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
end