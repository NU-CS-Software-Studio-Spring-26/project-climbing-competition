require "test_helper"

class FollowTest < ActiveSupport::TestCase
  test "requires unique follower and followed pair" do
    follow = Follow.new(follower: users(:one), followed: users(:two))

    assert_not follow.valid?
    assert_includes follow.errors[:followed_id], "has already been taken"
  end

  test "cannot follow yourself" do
    follow = Follow.new(follower: users(:one), followed: users(:one))

    assert_not follow.valid?
    assert_includes follow.errors[:base], "You cannot follow yourself."
  end

  test "creates a follow between two users" do
    follower = users(:one)
    followed = users(:two)
    Follow.where(follower: follower, followed: followed).delete_all

    follow = Follow.new(follower: follower, followed: followed)

    assert follow.save
    assert follower.following?(followed)
    assert_includes followed.followers, follower
  end
end
