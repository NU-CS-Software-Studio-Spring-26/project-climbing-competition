require "test_helper"

class UserTest < ActiveSupport::TestCase
  def valid_user_attributes(overrides = {})
    {
      name: "Valid User",
      username: "validuser#{SecureRandom.hex(4)}",
      email_address: "valid-#{SecureRandom.hex(4)}@example.com",
      password: "password123",
      password_confirmation: "password123"
    }.merge(overrides)
  end

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
    user = User.new(valid_user_attributes(username: "bad user!"))

    assert_not user.valid?
    assert_includes user.errors[:username], "is invalid"
  end

  test "accepts unicode display names" do
    user = User.new(valid_user_attributes(name: "José O'Brien"))
    assert user.valid?

    user = User.new(valid_user_attributes(name: "山田太郎"))
    assert user.valid?
  end

  test "rejects control characters in name and bio" do
    user = User.new(valid_user_attributes(name: "Bad\u0007Name"))
    assert_not user.valid?
    assert_includes user.errors[:name], "contains invalid characters"

    user = User.new(valid_user_attributes(bio: "Bio\u007fwith control"))
    assert_not user.valid?
    assert_includes user.errors[:bio], "contains invalid characters"
  end

  test "rejects names without letters" do
    user = User.new(valid_user_attributes(name: "---"))
    assert_not user.valid?
    assert_includes user.errors[:name], "must include at least one letter"

    user = User.new(valid_user_attributes(name: "123"))
    assert_not user.valid?
    assert_includes user.errors[:name], "must include at least one letter"
  end

  test "rejects email addresses over 254 characters" do
    local_part = "a" * 245
    user = User.new(valid_user_attributes(email_address: "#{local_part}@example.com"))

    assert_not user.valid?
    assert user.errors[:email_address].any? { |message| message.include?("too long") }
  end

  test "rejects passwords over 72 characters" do
    user = User.new(valid_user_attributes(password: "a" * 73, password_confirmation: "a" * 73))

    assert_not user.valid?
    assert user.errors[:password].any? { |message| message.include?("too long") }
  end

  test "rejects html-only username after sanitization" do
    user = User.new(valid_user_attributes(username: "<script></script>"))

    assert_not user.valid?
    assert user.errors[:username].any?
  end

  test "average_placement uses past competitions only" do
    user = users(:one)
    competition = competitions(:one)
    competition.update!(starts_at: 2.weeks.ago, ends_at: 1.week.ago)

    climb_one = climbs(:one)
    climb_two = climbs(:one_two)
    Attempt.where(climb: [ climb_one, climb_two ]).delete_all
    Attempt.create!(user: user, climb: climb_one, attempt_count: 1)
    Attempt.create!(user: users(:two), climb: climb_one, attempt_count: 2)

    assert_equal 1, competition.placement_for(user)
    assert_equal 1.0, user.average_placement
  end

  test "requires password confirmation when password is present" do
    user = User.new(valid_user_attributes(password_confirmation: "different-password"))

    assert_not user.valid?
    assert_includes user.errors[:password_confirmation], "doesn't match Password"
  end

  test "password account is resettable without google uid" do
    user = User.new(valid_user_attributes)

    assert user.password_resettable?
  end

  test "google-only account is not password resettable" do
    user = users(:google_only)

    assert_not user.password_resettable?
  end
end
