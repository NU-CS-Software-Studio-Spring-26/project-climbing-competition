require "test_helper"

class CompetitionTest < ActiveSupport::TestCase
  test "grade_range_tier follows peak grade" do
    competition = competitions(:one)
    competition.update!(v_grade_min: 0, v_grade_max: 3)
    assert_equal :v0_3, competition.grade_range_tier

    competition.update!(v_grade_min: 4, v_grade_max: 6)
    assert_equal :v4_6, competition.grade_range_tier

    competition.update!(v_grade_min: 7, v_grade_max: 9)
    assert_equal :v7_9, competition.grade_range_tier

    competition.update!(v_grade_min: 10, v_grade_max: 16)
    assert_equal :v10_plus, competition.grade_range_tier
  end

  test "leaderboard sorts by points then attempts then username" do
    competition = competitions(:one)
    user_one = users(:one)
    user_two = users(:two)

    climb_one = climbs(:one)
    climb_two = climbs(:one_two)

    Attempt.create!(user: user_one, climb: climb_one, attempt_count: 1, completed: true)
    Attempt.create!(user: user_two, climb: climb_one, attempt_count: 1, completed: true)
    Attempt.create!(user: user_two, climb: climb_two, attempt_count: 3, completed: false)

    leaderboard = competition.leaderboard_entries

    assert_equal [ user_one.username, user_two.username ], leaderboard.map { |entry| entry.user.username }
    assert_equal [ 15, 15 ], leaderboard.map(&:points)
    assert_equal [ 1, 4 ], leaderboard.map(&:attempts_count)
  end
end
