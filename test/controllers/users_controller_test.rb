require "test_helper"

class UsersControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:one)
    @other_user = users(:two)
  end

  test "should get new" do
    get new_user_url
    assert_response :success
  end

  test "should create user" do
    assert_difference("User.count") do
      post users_url, params: {
        user: {
          name: @user.name,
          username: "#{@user.username}-signup",
          email_address: "#{@user.username}+signup@example.com",
          bio: @user.bio,
          password: "password123",
          password_confirmation: "password123"
        }
      }
    end

    assert_redirected_to user_url(User.last)
  end

  test "should redirect show when unauthenticated" do
    get user_url(@user)
    assert_redirected_to new_session_url
  end

  test "should show own user profile" do
    post session_url, params: { session: { email_address: @user.email_address, password: "password123" } }

    get user_url(@user)
    assert_response :success
  end

  test "should not show another user profile" do
    post session_url, params: { session: { email_address: @user.email_address, password: "password123" } }

    get user_url(@other_user)
    assert_response :not_found
  end

  test "should get own edit" do
    post session_url, params: { session: { email_address: @user.email_address, password: "password123" } }

    get edit_user_url(@user)
    assert_response :success
  end

  test "should update own user" do
    post session_url, params: { session: { email_address: @user.email_address, password: "password123" } }

    patch user_url(@user), params: { user: { name: "Updated Name", username: @user.username } }
    assert_redirected_to user_url(@user)
    @user.reload
    assert_equal "Updated Name", @user.name
  end
end
