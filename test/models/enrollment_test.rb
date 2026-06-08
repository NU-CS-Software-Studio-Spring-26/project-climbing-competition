require "test_helper"

class EnrollmentTest < ActiveSupport::TestCase
  test "cannot enroll in a past competition" do
    competition = competitions(:two)
    set_competition_schedule(competition, starts_at: 2.weeks.ago, ends_at: 1.week.ago)

    enrollment = Enrollment.new(user: users(:one), competition: competition)

    assert_not enrollment.valid?
    assert_includes enrollment.errors[:base], "This competition has ended and is no longer open for joining."
  end

  test "can enroll in an active competition" do
    competition = competitions(:two)
    set_competition_schedule(competition, starts_at: 1.day.ago, ends_at: 1.week.from_now)

    enrollment = Enrollment.new(user: users(:one), competition: competition)

    assert enrollment.valid?
  end

  test "cannot leave enrollment when competition has ended" do
    competition = competitions(:one)
    enrollment = enrollments(:one_in_one)
    set_competition_schedule(competition, starts_at: 2.weeks.ago, ends_at: 1.week.ago)

    assert_no_difference("Enrollment.count") do
      assert_not enrollment.destroy
    end

    assert_includes enrollment.errors[:base], "This competition has ended. You can no longer leave it."
  end

  test "can destroy past competition and its enrollments" do
    competition = competitions(:one)
    set_competition_schedule(competition, starts_at: 2.weeks.ago, ends_at: 1.week.ago)
    enrollment_count = competition.enrollments.count

    assert enrollment_count.positive?
    assert_difference("Enrollment.count", -enrollment_count) do
      assert competition.destroy
    end
    assert_not Competition.exists?(competition.id)
  end

  test "can leave enrollment while competition is active" do
    competition = competitions(:two)
    set_competition_schedule(competition, starts_at: 1.day.ago, ends_at: 1.week.from_now)
    enrollment = Enrollment.create!(user: users(:one), competition: competition)

    assert_difference("Enrollment.count", -1) do
      assert enrollment.destroy
    end
  end
end
