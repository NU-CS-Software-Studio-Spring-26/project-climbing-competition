require "rails_helper"

RSpec.describe "Video submission review", type: :request do
  def create_user(name:, username_prefix:, email_prefix:)
    token = SecureRandom.hex(4)
    User.create!(
      name: name,
      username: "#{username_prefix}_#{token}",
      email_address: "#{email_prefix}_#{token}@example.com",
      password: "password123",
      password_confirmation: "password123"
    )
  end

  def sign_in_as(user)
    post session_path, params: {
      session: {
        email_address: user.email_address,
        password: "password123"
      }
    }
  end

  def build_competition(owner)
    competition = Competition.create!(
      name: "Video Review Comp #{SecureRandom.hex(3)}",
      starts_at: 1.week.from_now,
      ends_at: 2.weeks.from_now,
      flash_points: 30,
      attempt_deduction: 5,
      owner: owner,
      climbs_attributes: {
        "0" => { name: "Climb A", url: "https://example.com/a", grading: "V2" },
        "1" => { name: "Climb B", url: "https://example.com/b", grading: "V3" }
      }
    )
    competition.update_columns(starts_at: 1.day.ago, ends_at: 1.day.from_now)
    competition.reload
  end

  it "allows a host to review climb videos and mark a send invalid" do
    host = create_user(name: "Host", username_prefix: "host", email_prefix: "host")
    competitor = create_user(name: "Competitor", username_prefix: "competitor", email_prefix: "competitor")
    competition = build_competition(host)
    climb = competition.climbs.first

    attempt = Attempt.create!(user: competitor, climb: climb, attempt_count: 1)
    attempt.submission_video.attach(
      io: StringIO.new("fake video bytes"),
      filename: "submission.mp4",
      content_type: "video/mp4"
    )

    sign_in_as(host)

    get competition_climb_video_reviews_path(competition, climb)
    expect(response).to have_http_status(:ok)
    expect(response.body).to include("review video submissions")

    patch invalidate_competition_climb_attempt_path(competition, climb, attempt), params: { index: 0 }
    expect(response).to redirect_to(competition_climb_video_reviews_path(competition, climb, index: 0))

    attempt.reload
    expect(attempt.invalidated?).to be(true)
    expect(attempt.points_awarded).to eq(0)
  end

  it "prevents non-host users from reviewing other climbers' submissions" do
    host = create_user(name: "Host", username_prefix: "host", email_prefix: "host")
    competitor = create_user(name: "Competitor", username_prefix: "competitor", email_prefix: "competitor")
    other_user = create_user(name: "Viewer", username_prefix: "viewer", email_prefix: "viewer")
    competition = build_competition(host)
    climb = competition.climbs.first

    attempt = Attempt.create!(user: competitor, climb: climb, attempt_count: 2)
    attempt.submission_video.attach(
      io: StringIO.new("fake video bytes"),
      filename: "submission.mp4",
      content_type: "video/mp4"
    )

    sign_in_as(other_user)

    get competition_climb_video_reviews_path(competition, climb)
    expect(response).to redirect_to(competition_path(competition))

    patch invalidate_competition_climb_attempt_path(competition, climb, attempt), params: { index: 0 }
    expect(response).to redirect_to(competition_path(competition))

    attempt.reload
    expect(attempt.invalidated?).to be(false)
  end
end
