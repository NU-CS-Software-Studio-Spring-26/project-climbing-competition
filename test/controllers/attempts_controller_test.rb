require "test_helper"

class AttemptsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @competition = competitions(:one)
    set_competition_schedule(@competition, starts_at: 1.day.ago, ends_at: 1.week.from_now)
    @climb = climbs(:one)
    @user = users(:one)
  end

  def sign_in_as(user)
    post session_url, params: { session: { email_address: user.email_address, password: "password123" } }
  end

  test "should require authentication to log an attempt" do
    assert_no_difference("Attempt.count") do
      post competition_climb_attempt_url(@competition, @climb), params: { attempt: { attempt_count: 3 } }
    end

    assert_redirected_to new_session_url
  end

  test "should create an attempt for an enrolled user" do
    sign_in_as(@user)

    assert_difference("Attempt.count", 1) do
      post competition_climb_attempt_url(@competition, @climb), params: { attempt: { attempt_count: 1 } }
    end

    attempt = Attempt.last
    assert_equal @user, attempt.user
    assert_equal @climb, attempt.climb
    assert_equal 30, attempt.points_awarded  # flash_points(30)
    assert_redirected_to competition_path(@competition)
  end

  test "should reject attempt logging before competition starts" do
    @competition.update!(starts_at: 1.week.from_now, ends_at: 2.weeks.from_now)
    sign_in_as(@user)

    assert_no_difference("Attempt.count") do
      post competition_climb_attempt_url(@competition, @climb), params: { attempt: { attempt_count: 1 } }
    end

    assert_redirected_to competition_path(@competition)
    assert_match(/not available until the competition starts/i, flash[:alert].to_s)
  end

  test "should reject attempt logging for a non enrolled user" do
    sign_in_as(@user)
    other_competition = competitions(:two)
    other_climb = climbs(:two)

    assert_no_difference("Attempt.count") do
      post competition_climb_attempt_url(other_competition, other_climb), params: { attempt: { attempt_count: 2 } }
    end

    assert_redirected_to competition_path(other_competition)
  end
end
