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
    @competition.update!(starts_at: 2.weeks.ago, ends_at: 1.week.ago)
    sign_in_as(@user)

    assert_no_difference("Enrollment.count") do
      post competition_enrollments_url(@competition)
    end

    assert_redirected_to competition_url(@competition)
    assert_equal "This competition has ended and is no longer open for joining.", flash[:alert]
  end

  test "can join an active competition" do
    @competition.update!(starts_at: 1.day.ago, ends_at: 1.week.from_now)
    assert_not @user.competitions.include?(@competition)
    sign_in_as(@user)

    assert_difference("Enrollment.count", 1) do
      post competition_enrollments_url(@competition)
    end

    assert_redirected_to competition_url(@competition)
    assert_equal "You have joined the competition!", flash[:notice]
  end
end
