require "test_helper"

class FriendsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:one)
    @friend = users(:two)
    Follow.find_or_create_by!(follower: @user, followed: @friend)
  end

  def sign_in_as(user)
    post session_url, params: { session: { email_address: user.email_address, password: "password123" } }
  end

  test "requires authentication" do
    get friends_url

    assert_redirected_to new_session_path
  end

  test "shows friends feed when signed in" do
    sign_in_as(@user)

    get friends_url

    assert_response :success
    assert_match "recent updates from climbers you follow", response.body
    assert_select ".friends-activity-card", minimum: 0
  end

  test "shows empty state when not following anyone" do
    Follow.where(follower: @user).delete_all
    sign_in_as(@user)

    get friends_url

    assert_response :success
    assert_match "not following anyone", response.body
  end
end
