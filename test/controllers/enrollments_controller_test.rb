require "test_helper"

class EnrollmentsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @competition = competitions(:two)
    @user = users(:one)
  end

  def sign_in_as(user)
    post session_url, params: { session: { email_address: user.email_address, password: "password123" } }
  end

  test "cannot join a past competition" do
    set_competition_schedule(@competition, starts_at: 2.weeks.ago, ends_at: 1.week.ago)
    sign_in_as(@user)

    assert_no_difference("Enrollment.count") do
      post competition_enrollments_url(@competition)
    end

    assert_redirected_to competition_url(@competition)
    assert_equal "This competition has ended and is no longer open for joining.", flash[:alert]
  end

  test "can join an active competition" do
    set_competition_schedule(@competition, starts_at: 1.day.ago, ends_at: 1.week.from_now)
    assert_not @user.competitions.include?(@competition)
    sign_in_as(@user)

    assert_difference("Enrollment.count", 1) do
      post competition_enrollments_url(@competition)
    end

    assert_redirected_to competition_url(@competition)
    assert_equal "You have joined the competition!", flash[:notice]
  end

  test "cannot leave a past competition" do
    set_competition_schedule(@competition, starts_at: 1.day.ago, ends_at: 1.week.from_now)
    sign_in_as(@user)
    post competition_enrollments_url(@competition)
    set_competition_schedule(@competition, starts_at: 2.weeks.ago, ends_at: 1.week.ago)
    enrollment = @competition.enrollments.find_by!(user: @user)

    assert_no_difference("Enrollment.count") do
      delete competition_enrollment_url(@competition, enrollment)
    end

    assert_redirected_to competition_url(@competition)
    assert_equal "This competition has ended. You can no longer leave it.", flash[:alert]
  end

  test "can leave an active competition" do
    set_competition_schedule(@competition, starts_at: 1.day.ago, ends_at: 1.week.from_now)
    sign_in_as(@user)
    post competition_enrollments_url(@competition)
    enrollment = @competition.enrollments.find_by!(user: @user)

    assert_difference("Enrollment.count", -1) do
      delete competition_enrollment_url(@competition, enrollment)
    end

    assert_redirected_to competition_url(@competition)
    assert_equal "You have left the competition.", flash[:notice]
  end
end
