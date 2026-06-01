require "test_helper"

class FollowsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:one)
    @other_user = users(:two)
    Follow.where(follower: @user, followed: @other_user).delete_all
  end

  def sign_in_as(user)
    post session_url, params: { session: { email_address: user.email_address, password: "password123" } }
  end

  test "requires authentication to follow" do
    post user_follow_url(@other_user)

    assert_redirected_to new_session_path
  end

  test "can follow another user" do
    sign_in_as(@user)

    assert_difference("Follow.count", 1) do
      post user_follow_url(@other_user)
    end

    assert_redirected_to user_url(@other_user)
    assert_equal "You are now following #{@other_user.username}.", flash[:notice]
    assert @user.following?(@other_user)
  end

  test "cannot follow yourself" do
    sign_in_as(@user)

    assert_no_difference("Follow.count") do
      post user_follow_url(@user)
    end

    assert_redirected_to user_url(@user)
    assert_equal "You cannot follow yourself.", flash[:alert]
  end

  test "can unfollow a user" do
    Follow.create!(follower: @user, followed: @other_user)
    sign_in_as(@user)

    assert_difference("Follow.count", -1) do
      delete user_follow_url(@other_user)
    end

    assert_redirected_to user_url(@other_user)
    assert_equal "You unfollowed #{@other_user.username}.", flash[:notice]
    assert_not @user.following?(@other_user)
  end

  test "cannot unfollow when not following" do
    sign_in_as(@user)

    assert_no_difference("Follow.count") do
      delete user_follow_url(@other_user)
    end

    assert_redirected_to user_url(@other_user)
    assert_equal "You are not following this user.", flash[:alert]
  end
end
