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
      attempt_count: 2,
      completed: true
    )

    expect(attempt.points_awarded).to eq(competition.score_for_climb(sent: true, flashed: false, attempts: 2))
  end

  it "requires a video file when video submissions are required and the climb is marked completed" do
    skip("Implement this once Competition has video_submissions_required and Attempt has submission_video attachment")
  end

  it "deducts points after host marks a submitted send as invalid" do
    skip("Implement this once Attempt has a host review status and invalid state")
  end
end
