require "test_helper"

class EnrollmentTest < ActiveSupport::TestCase
  test "cannot enroll in a past competition" do
    competition = competitions(:two)
    competition.update!(starts_at: 2.weeks.ago, ends_at: 1.week.ago)

    enrollment = Enrollment.new(user: users(:one), competition: competition)

    assert_not enrollment.valid?
    assert_includes enrollment.errors[:base], "This competition has ended and is no longer open for joining."
  end

  test "can enroll in an active competition" do
    competition = competitions(:two)
    competition.update!(starts_at: 1.day.ago, ends_at: 1.week.from_now)

    enrollment = Enrollment.new(user: users(:one), competition: competition)

    assert enrollment.valid?
  end
end
