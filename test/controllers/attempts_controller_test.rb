require "test_helper"

class AttemptsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @competition = competitions(:one)
    @climb = climbs(:one)
    @user = users(:one)
  end

  def sign_in_as(user)
    post session_url, params: { session: { email_address: user.email_address, password: "password123" } }
  end

  test "should require authentication to log an attempt" do
    assert_no_difference("Attempt.count") do
      post competition_climb_attempt_url(@competition, @climb), params: { attempt: { attempt_count: 3, completed: true } }
    end

    assert_redirected_to new_session_url
  end

  test "should create an attempt for an enrolled user" do
    sign_in_as(@user)

    assert_difference("Attempt.count", 1) do
      post competition_climb_attempt_url(@competition, @climb), params: { attempt: { attempt_count: 1, completed: true } }
    end

    attempt = Attempt.last
    assert_equal @user, attempt.user
    assert_equal @climb, attempt.climb
    assert_equal 30, attempt.points_awarded  # flash_points(30)
    assert_redirected_to competition_url(@competition, anchor: "leaderboard")
  end

  test "should reject attempt logging for a non enrolled user" do
    sign_in_as(@user)
    other_competition = competitions(:two)
    other_climb = climbs(:two)

    assert_no_difference("Attempt.count") do
      post competition_climb_attempt_url(other_competition, other_climb), params: { attempt: { attempt_count: 2, completed: false } }
    end

    assert_redirected_to competition_path(other_competition)
  end
end
