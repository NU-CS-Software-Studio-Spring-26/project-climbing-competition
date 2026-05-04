require "test_helper"

class AttemptTest < ActiveSupport::TestCase
  test "awards points for a completed climb" do
    attempt = Attempt.new(user: users(:one), climb: climbs(:one), attempt_count: 2, completed: true)

    assert attempt.valid?
    assert_equal 10, attempt.points_awarded
  end

  test "awards bonus points for a one-attempt send" do
    attempt = Attempt.new(user: users(:one), climb: climbs(:one), attempt_count: 1, completed: true)

    assert attempt.valid?
    assert_equal 15, attempt.points_awarded
  end

  test "rejects invalid attempt counts" do
    attempt = Attempt.new(user: users(:one), climb: climbs(:one), attempt_count: 0, completed: false)

    assert_not attempt.valid?
    assert_includes attempt.errors[:attempt_count], "is invalid"
  end

  test "rejects non integer attempt counts" do
    attempt = Attempt.new(user: users(:one), climb: climbs(:one), attempt_count: "3.5", completed: false)

    assert_not attempt.valid?
    assert_includes attempt.errors[:attempt_count], "is invalid"
  end
end
