require "test_helper"

class CompetitionTest < ActiveSupport::TestCase
  test "leaderboard sorts by points then attempts then username" do
    competition = competitions(:one)
    user_one = users(:one)
    user_two = users(:two)

    Enrollment.create!(user: user_one, competition: competition)
    Enrollment.create!(user: user_two, competition: competition)

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
