require "test_helper"

class UserTest < ActiveSupport::TestCase
  test "sanitizes profile text fields" do
    user = User.new(
      name: "<b>Alice</b>",
      username: "<script>alice-clean</script>",
      email_address: "alice+clean@example.com",
      bio: "<img src=x onerror=alert(1)>Strong climber",
      password: "password123",
      password_confirmation: "password123"
    )

    assert user.valid?
    assert_equal "Alice", user.name
    assert_equal "alice-clean", user.username
    assert_equal "Strong climber", user.bio
  end

  test "rejects usernames with invalid characters" do
    user = User.new(
      name: "Invalid User",
      username: "bad user!",
      email_address: "invalid-user@example.com",
      password: "password123",
      password_confirmation: "password123"
    )

    assert_not user.valid?
    assert_includes user.errors[:username], "is invalid"
  end
end
