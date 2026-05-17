require "test_helper"

class UsersControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:one)
    @other_user = users(:two)
  end

  def sign_in_as(user)
    post session_url, params: { session: { email_address: user.email_address, password: "password123" } }
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

  test "should show user profile when unauthenticated" do
    get user_url(@user)
    assert_response :success
    assert_match @user.username, response.body
    assert_no_match @user.email_address, response.body
  end

  test "should show another user profile when authenticated" do
    sign_in_as(@user)

    get user_url(@other_user)
    assert_response :success
    assert_match @other_user.username, response.body
    assert_no_match @other_user.email_address, response.body
  end

  test "should show own email on own profile when authenticated" do
    sign_in_as(@user)

    get user_url(@user)
    assert_response :success
    assert_match @user.email_address, response.body
  end

  test "should list enrolled competition in past bucket after event ends" do
    travel_to Time.zone.parse("2026-05-16 12:00:00") do
      get user_url(@user)
      assert_response :success
      assert_match "Past competitions", response.body
      assert_match competitions(:one).name, response.body
    end
  end

  test "should get own edit" do
    sign_in_as(@user)

    get edit_user_url(@user)
    assert_response :success
  end

  test "should update own user" do
    sign_in_as(@user)

    patch user_url(@user), params: { user: { name: "Updated Name", username: @user.username } }
    assert_redirected_to user_url(@user)
    @user.reload
    assert_equal "Updated Name", @user.name
  end
end
