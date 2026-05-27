require "test_helper"

class CompetitionTest < ActiveSupport::TestCase
  test "grade_range_tier follows peak grade" do
    competition = competitions(:one)

    competition.v_grade_max = 3
    assert_equal :v0_3, competition.grade_range_tier

    competition.v_grade_max = 6
    assert_equal :v4_6, competition.grade_range_tier

    competition.v_grade_max = 9
    assert_equal :v7_9, competition.grade_range_tier

    competition.v_grade_max = 16
    assert_equal :v10_plus, competition.grade_range_tier
  end

  test "climb_grade_range_label reflects climb gradings" do
    competition = competitions(:one)
    assert_equal "V2–V3", competition.climb_grade_range_label
  end

  test "climb_grade_range_label shows V10+ when lowest climb is V10 or harder" do
    competition = competitions(:one)
    competition.climbs.each { |climb| climb.update!(grading: "V10") }
    assert_equal "V10+", competition.climb_grade_range_label

    competition.climbs.first.update!(grading: "V12")
    assert_equal "V10+", competition.climb_grade_range_label
  end

  test "derives level and grade range from climb gradings" do
    competition = Competition.new(
      name: "Auto Level Comp",
      starts_at: 1.day.from_now,
      ends_at: 2.days.from_now,
      send_points: 25,
      flash_points: 30,
      attempt_deduction: 5
    )
    competition.climbs.build(name: "A", url: "https://example.com/a", grading: "V4")
    competition.climbs.build(name: "B", url: "https://example.com/b", grading: "V6")

    assert competition.valid?
    assert_equal "intermediate", competition.level
    assert_equal 4, competition.v_grade_min
    assert_equal 6, competition.v_grade_max
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
    assert_equal [ 30, 30 ], leaderboard.map(&:points)  # flash_points(30) for both
    assert_equal [ 1, 4 ], leaderboard.map(&:attempts_count)
  end
end
