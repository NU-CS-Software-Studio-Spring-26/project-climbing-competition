require "test_helper"

class FriendActivityFeedTest < ActiveSupport::TestCase
  setup do
    @viewer = users(:one)
    @friend = users(:two)
    Follow.where(follower: @viewer, followed: @friend).first_or_create!
  end

  test "returns empty activities when not following anyone" do
    Follow.where(follower: @viewer).delete_all

    assert_empty FriendActivityFeed.for(@viewer)
  end

  test "includes enrollment when friend joins competition" do
    competition = competitions(:two)
    competition.update!(starts_at: 1.day.ago, ends_at: 1.week.from_now)
    Enrollment.where(user: @friend, competition: competition).delete_all
    enrollment = Enrollment.create!(user: @friend, competition: competition)

    activities = FriendActivityFeed.for(@viewer)
    joined = activities.find { |activity| activity.kind == :joined && activity.user == @friend && activity.competition == competition }

    assert joined
    assert_in_delta enrollment.created_at.to_i, joined.occurred_at.to_i, 2
  end

  test "includes attempt when friend logs climb" do
    competition = competitions(:one)
    competition.update!(starts_at: 1.day.ago, ends_at: 1.week.from_now)
    climb = climbs(:one)
    attempt = Attempt.find_or_initialize_by(user: @friend, climb: climb)
    attempt.update!(attempt_count: 2, updated_at: Time.current)

    activities = FriendActivityFeed.for(@viewer)
    logged = activities.find { |activity| activity.kind == :attempt && activity.user == @friend && activity.attempt == attempt }

    assert logged
    assert_equal climb, logged.climb
  end

  test "includes placement for friend in past competition" do
    competition = competitions(:one)
    competition.update!(starts_at: 2.weeks.ago, ends_at: 1.week.ago)
    Enrollment.find_or_create_by!(user: @friend, competition: competition)

    activities = FriendActivityFeed.for(@viewer)
    placed = activities.find { |activity| activity.kind == :placed && activity.user == @friend && activity.competition == competition }

    assert placed
    assert placed.placement.positive?
    assert_equal competition.ends_at, placed.occurred_at
  end

  test "limits to 15 activities" do
    20.times do |index|
      competition = Competition.create!(
        name: "Feed Comp #{index}",
        starts_at: 1.day.ago,
        ends_at: 1.week.from_now,
        send_points: 25,
        flash_points: 30,
        attempt_deduction: 5,
        owner: @viewer,
        v_grade_min: 0,
        v_grade_max: 3,
        climbs_attributes: {
          "0" => { name: "A", url: "https://example.com/a", grading: "V1" },
          "1" => { name: "B", url: "https://example.com/b", grading: "V2" }
        }
      )
      Enrollment.create!(user: @friend, competition: competition)
    end

    assert_equal 15, FriendActivityFeed.for(@viewer).size
  end

  test "sorts activities newest first" do
    competition = competitions(:two)
    competition.update!(starts_at: 1.day.ago, ends_at: 1.week.from_now)
    Enrollment.where(user: @friend, competition: competition).delete_all
    Enrollment.create!(user: @friend, competition: competition)

    activities = FriendActivityFeed.for(@viewer)
    timestamps = activities.map(&:occurred_at)

    assert_equal timestamps.sort.reverse, timestamps
  end
end
