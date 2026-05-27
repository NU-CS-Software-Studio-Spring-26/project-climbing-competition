require "test_helper"

class AttemptTest < ActiveSupport::TestCase
  test "awards points for a completed climb" do
    attempt = Attempt.new(user: users(:one), climb: climbs(:one), attempt_count: 2, completed: true)

    assert attempt.valid?
    assert_equal 20, attempt.points_awarded  # send_points(25) - 1 extra attempt * deduction(5)
  end

  test "awards bonus points for a one-attempt send" do
    attempt = Attempt.new(user: users(:one), climb: climbs(:one), attempt_count: 1, completed: true)

    assert attempt.valid?
    assert_equal 30, attempt.points_awarded  # flash_points(30)
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

  test "rejects attempt counts longer than the allowed input length" do
    attempt = Attempt.new(user: users(:one), climb: climbs(:one), attempt_count: "101", completed: false)

    assert_not attempt.valid?
    assert_includes attempt.errors[:attempt_count], "is invalid"
  end
end
