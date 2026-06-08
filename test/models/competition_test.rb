require "test_helper"

class CompetitionTest < ActiveSupport::TestCase
  test "grade_range_tier follows peak grade from climbs" do
    competition = competitions(:one)
    assert_equal :v0_3, competition.grade_range_tier

    competition.climbs.each { |climb| climb.update!(grading: "V6") }
    competition.reload
    assert_equal :v4_6, competition.grade_range_tier

    competition.climbs.each { |climb| climb.update!(grading: "V9") }
    competition.reload
    assert_equal :v7_9, competition.grade_range_tier

    competition.climbs.each { |climb| climb.update!(grading: "V12") }
    competition.reload
    assert_equal :v10_plus, competition.grade_range_tier
  end

  test "climb_grade_range_label reflects climb gradings" do
    competition = competitions(:one)
    assert_equal "V2–V3", competition.climb_grade_range_label
  end

  test "climb_grade_range_label shows V10+ when lowest climb is V10 or harder" do
    competition = competitions(:one)
    competition.climbs.each { |climb| climb.update!(grading: "V10") }
    competition.reload
    assert_equal "V10+", competition.climb_grade_range_label

    competition.climbs.first.update!(grading: "V12")
    competition.reload
    assert_equal "V10+", competition.climb_grade_range_label
  end

  test "derives level and grade range from climb gradings" do
    competition = Competition.new(
      name: "Auto Level Comp",
      starts_at: 1.day.from_now,
      ends_at: 2.days.from_now,
      flash_points: 30,
      attempt_deduction: 5,
      owner: users(:one)
    )
    competition.climbs.build(name: "A", url: "https://example.com/a", grading: "V4")
    competition.climbs.build(name: "B", url: "https://example.com/b", grading: "V6")

    assert competition.valid?
    assert_equal "intermediate", competition.level
    assert_equal 4, competition.v_grade_min
    assert_equal 6, competition.v_grade_max
  end

  test "placement_for returns rank for enrolled user" do
    competition = competitions(:one)
    user_one = users(:one)
    user_two = users(:two)

    climb_one = climbs(:one)
    climb_two = climbs(:one_two)

    Attempt.create!(user: user_one, climb: climb_one, attempt_count: 1)
    Attempt.create!(user: user_two, climb: climb_one, attempt_count: 1)
    Attempt.create!(user: user_two, climb: climb_two, attempt_count: 3, invalidated: true)

    assert_equal 1, competition.placement_for(user_one)
    assert_equal 2, competition.placement_for(user_two)

    outsider = User.create!(
      name: "Outside Climber",
      username: "outsider#{SecureRandom.hex(3)}",
      email_address: "outsider-#{SecureRandom.hex(3)}@example.com",
      password: "password123",
      password_confirmation: "password123"
    )
    assert_nil competition.placement_for(outsider)
  end

  test "leaderboard sorts by points then attempts then username" do
    competition = competitions(:one)
    user_one = users(:one)
    user_two = users(:two)

    climb_one = climbs(:one)
    climb_two = climbs(:one_two)

    Attempt.create!(user: user_one, climb: climb_one, attempt_count: 1)
    Attempt.create!(user: user_two, climb: climb_one, attempt_count: 1)
    Attempt.create!(user: user_two, climb: climb_two, attempt_count: 3, invalidated: true)

    leaderboard = competition.leaderboard_entries

    assert_equal [ user_one.username, user_two.username ], leaderboard.map { |entry| entry.user.username }
    assert_equal [ 30, 30 ], leaderboard.map(&:points)  # flash_points(30) for both
    assert_equal [ 1, 4 ], leaderboard.map(&:attempts_count)
  end

  test "leaderboard_csv includes summary and per-climb stats" do
    competition = competitions(:one)
    user_one = users(:one)
    user_two = users(:two)
    climb_one = climbs(:one)
    climb_two = climbs(:one_two)

    Attempt.create!(user: user_one, climb: climb_one, attempt_count: 1)
    Attempt.create!(user: user_two, climb: climb_one, attempt_count: 1)
    Attempt.create!(user: user_two, climb: climb_two, attempt_count: 3, invalidated: true)

    csv = CSV.parse(competition.leaderboard_csv, headers: true)

    assert_equal [ "1", "2" ], csv["Rank"]
    assert_equal [ user_one.email_address, user_two.email_address ], csv["Email"]
    assert_includes csv.headers, "#{climb_one.name} (Points)"
    assert_equal "Sent", csv[0]["#{climb_one.name} (Status)"]
    assert_equal "Invalidated", csv[1]["#{climb_two.name} (Status)"]
  end

  test "within_grade_range uses climb grades shown on competition cards" do
    beginner = competitions(:one)
    advanced = competitions(:two)

    climbs(:one).update!(grading: "V1")
    climbs(:one_two).update!(grading: "V8")
    climbs(:two).update!(grading: "V5")
    climbs(:two_two).update!(grading: "V7")

    assert_not_includes Competition.within_grade_range(4, 8), beginner
    assert_includes Competition.within_grade_range(4, 8), advanced

    climbs(:one).update!(grading: "V4")
    assert_includes Competition.within_grade_range(4, 8), beginner.reload

    climbs(:one_two).update!(grading: "V11")
    assert_not_includes Competition.within_grade_range(4, 8), beginner.reload
  end

  test "ordered_by_status lists active, then upcoming, then past" do
    active = competitions(:one)
    set_competition_schedule(active, starts_at: 1.day.ago, ends_at: 1.week.from_now)

    upcoming = competitions(:two)
    upcoming.update!(starts_at: 1.week.from_now, ends_at: 2.weeks.from_now)

    past = Competition.create!(
      name: "Archived Comp",
      starts_at: 1.week.from_now,
      ends_at: 2.weeks.from_now,
      flash_points: 30,
      attempt_deduction: 5,
      owner: users(:one),
      climbs_attributes: {
        "0" => { name: "A", url: "https://example.com/a", grading: "V2" },
        "1" => { name: "B", url: "https://example.com/b", grading: "V3" }
      }
    )
    set_competition_schedule(past, starts_at: 3.weeks.ago, ends_at: 2.weeks.ago)

    ordered_ids = Competition.ordered_by_status.where(id: [ active.id, upcoming.id, past.id ]).pluck(:id)
    assert_equal [ active.id, upcoming.id, past.id ], ordered_ids
  end

  test "joinable? is false when competition has ended" do
    competition = competitions(:one)
    set_competition_schedule(competition, starts_at: 2.weeks.ago, ends_at: 1.week.ago)

    assert competition.past?
    assert_not competition.joinable?
  end

  test "joinable? is true for upcoming and active competitions" do
    competition = competitions(:two)
    competition.update!(starts_at: 1.day.from_now, ends_at: 1.week.from_now)
    assert_not competition.past?
    assert competition.joinable?

    set_competition_schedule(competition, starts_at: 1.day.ago, ends_at: 1.week.from_now)
    assert_equal :active, competition.status
    assert competition.joinable?
  end

  test "leavable? is false when competition has ended" do
    competition = competitions(:one)
    set_competition_schedule(competition, starts_at: 2.weeks.ago, ends_at: 1.week.ago)

    assert competition.past?
    assert_not competition.leavable?
  end

  test "leavable? is true for upcoming and active competitions" do
    competition = competitions(:two)
    competition.update!(starts_at: 1.day.from_now, ends_at: 1.week.from_now)
    assert competition.leavable?

    set_competition_schedule(competition, starts_at: 1.day.ago, ends_at: 1.week.from_now)
    assert competition.leavable?
  end

  test "started? and climbs_visible_to? follow competition schedule" do
    competition = competitions(:one)
    competition.update!(starts_at: 1.day.from_now, ends_at: 1.week.from_now)

    assert_not competition.started?
    assert_not competition.climbs_visible_to?(users(:two))
    assert competition.climbs_visible_to?(users(:one))

    set_competition_schedule(competition, starts_at: 1.day.ago, ends_at: 1.week.from_now)

    assert competition.started?
    assert competition.climbs_visible_to?(users(:two))
    assert competition.climbs_visible_to?(nil)
  end

  test "editable? is true only before competition starts" do
    competition = competitions(:one)
    competition.update!(starts_at: 1.day.from_now, ends_at: 1.week.from_now)
    assert competition.editable?

    set_competition_schedule(competition, starts_at: 1.day.ago, ends_at: 1.week.from_now)
    assert_not competition.editable?

    set_competition_schedule(competition, starts_at: 2.weeks.ago, ends_at: 1.week.ago)
    assert_not competition.editable?
  end

  test "rejects start date before today" do
    competition = competitions(:one)
    competition.starts_at = 1.day.ago
    competition.ends_at = 1.week.from_now

    assert_not competition.valid?
    assert_includes competition.errors[:starts_at], "cannot be before today's date"
  end

  test "rejects end date before today" do
    competition = competitions(:one)
    competition.starts_at = 1.day.from_now
    competition.ends_at = 1.day.ago

    assert_not competition.valid?
    assert_includes competition.errors[:ends_at], "cannot be before today's date"
  end

  test "rejects scoring values above the allowed maximum" do
    competition = competitions(:one)
    competition.flash_points = Competition::FLASH_POINTS_MAX + 1

    assert_not competition.valid?
    assert_includes competition.errors[:flash_points], "must be less than or equal to #{Competition::FLASH_POINTS_MAX}"
  end

  test "is invalid when end datetime is before start datetime" do
    competition = Competition.new(
      name: "Timing Check Comp",
      starts_at: 2.days.from_now,
      ends_at: 1.day.from_now,
      flash_points: 30,
      attempt_deduction: 5,
      owner: users(:one)
    )
    competition.climbs.build(name: "A", url: "https://example.com/a", grading: "V4")
    competition.climbs.build(name: "B", url: "https://example.com/b", grading: "V6")

    assert_not competition.valid?
    assert_includes competition.errors[:ends_at], "must be after the start date and time"
  end

  test "rejects new climbs outside locked grade range on update" do
    competition = competitions(:one)

    competition.climbs.build(name: "Too hard", url: "https://example.com/hard", grading: "V8")
    assert_not competition.valid?(:update)
    assert_includes competition.errors[:base].join, "New climbs must use grades within"
  end
end
