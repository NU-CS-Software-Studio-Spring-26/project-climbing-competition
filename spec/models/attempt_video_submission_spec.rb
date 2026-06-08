require "rails_helper"
RSpec.describe Attempt, type: :model do
  def create_competition_with_climbs(owner:)
    competition = Competition.create!(
      owner: owner,
      name: "Video Rules Cup",
      starts_at: Time.zone.now + 1.day,
      ends_at: Time.zone.now + 2.days,
      send_points: 25,
      flash_points: 30,
      attempt_deduction: 5,
      climbs_attributes: [
        { name: "Warmup", grading: "V2", url: "https://example.com/1" },
        { name: "Project", grading: "V4", url: "https://example.com/2" }
      ]
    )

    climbs = competition.climbs.order(:id).to_a

    [ competition, climbs ]
  end

  it "awards points immediately for a completed send by default" do
    user = User.create!(
      name: "Test Climber",
      username: "test_climber",
      email_address: "test_climber@example.com",
      password: "password123",
      password_confirmation: "password123"
    )

    competition, climbs = create_competition_with_climbs(owner: user)

    attempt = Attempt.create!(
      user: user,
      climb: climbs.first,
      attempt_count: 2
    )

    expect(attempt.points_awarded).to eq(competition.score_for_climb(sent: true, flashed: false, attempts: 2))
  end

  it "deducts points after host marks a submitted send as invalid" do
    user = User.create!(
      name: "Reviewable Climber",
      username: "reviewable_climber",
      email_address: "reviewable_climber@example.com",
      password: "password123",
      password_confirmation: "password123"
    )

    competition, climbs = create_competition_with_climbs(owner: user)

    attempt = Attempt.create!(
      user: user,
      climb: climbs.first,
      attempt_count: 2
    )

    expect(attempt.points_awarded).to be > 0

    attempt.update!(invalidated: true)

    expect(attempt.points_awarded).to eq(0)
  end
end
