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
      assert_match "Past (", response.body
      assert_match competitions(:one).name, response.body
    end
  end

  test "should show public stats on another user profile" do
    get user_url(@other_user)

    assert_response :success
    assert_match "Competitions entered", response.body
    assert_match "Average placement", response.body
    assert_match "Competitions", response.body
    assert_select "button.profile-tabs__tab", text: /Current/
    assert_no_match "Edit profile", response.body
    assert_no_match "Followers (", response.body
  end

  test "should show followers and following on own profile" do
    sign_in_as(@user)

    get user_url(@user)

    assert_response :success
    assert_match "Connections", response.body
    assert_select "button.profile-tabs__tab", text: "Following (1)"
    assert_match @other_user.name, response.body
    assert_select "button.profile-tabs__tab", text: "Followers (0)"
    assert_select ".profile-hero-aside .profile-aside-label", text: "Member since"
    assert_select ".profile-hero-aside .profile-aside-label", text: "Email"
    assert_select ".profile-hero-aside .profile-aside-value--email", text: @user.email_address
  end

  test "should show follow button on another user profile when signed in" do
    Follow.where(follower: @user, followed: @other_user).delete_all
    sign_in_as(@user)

    get user_url(@other_user)

    assert_response :success
    assert_select "form[action='#{user_follow_path(@other_user)}'] button", text: "Follow"
  end

  test "should show unfollow button when already following" do
    Follow.find_or_create_by!(follower: @user, followed: @other_user)
    sign_in_as(@user)

    get user_url(@other_user)

    assert_response :success
    assert_select "form[action='#{user_follow_path(@other_user)}'] input[name='_method'][value='delete']"
    assert_select "form[action='#{user_follow_path(@other_user)}'] button", text: "Unfollow"
  end

  test "competition show links creator name to profile" do
    competition = competitions(:one)

    get competition_url(competition)

    assert_response :success
    assert_select "a.competition-hero-creator-link[href='#{user_path(competition.owner)}']", text: competition.owner.name
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

  test "should not create user with script payloads in profile fields" do
    assert_no_difference("User.count") do
      post users_url, params: {
        user: {
          name: "<script></script>",
          username: "<script></script>",
          email_address: "new-user@example.com",
          bio: "<img src=x onerror=alert(1)>",
          password: "password123",
          password_confirmation: "password123"
        }
      }
    end

    assert_response :unprocessable_entity
    assert_match "error", response.body
  end

  test "should not create user with oversized name" do
    assert_no_difference("User.count") do
      post users_url, params: {
        user: valid_signup_params(name: "a" * 81)
      }
    end

    assert_response :unprocessable_entity
    assert_match "error", response.body
  end

  test "should handle missing user params on create" do
    assert_no_difference("User.count") do
      post users_url, params: {}
    end

    assert_response :unprocessable_entity
    assert_match "Please fill out the profile form.", response.body
  end

  test "should not create user with duplicate username" do
    assert_no_difference("User.count") do
      post users_url, params: {
        user: valid_signup_params(username: @user.username, email_address: "duplicate-username@example.com")
      }
    end

    assert_response :unprocessable_entity
    assert_match "Username has already been taken", response.body
  end

  test "should not create user with duplicate email" do
    assert_no_difference("User.count") do
      post users_url, params: {
        user: valid_signup_params(username: "unique-username", email_address: @user.email_address)
      }
    end

    assert_response :unprocessable_entity
    assert_match "Email address has already been taken", response.body
  end

  private
    def valid_signup_params(overrides = {})
      {
        name: "New Climber",
        username: "newclimber#{SecureRandom.hex(4)}",
        email_address: "newclimber-#{SecureRandom.hex(4)}@example.com",
        bio: "Boulderer",
        password: "password123",
        password_confirmation: "password123"
      }.merge(overrides)
    end
end
