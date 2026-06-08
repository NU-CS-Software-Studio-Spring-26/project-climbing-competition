require "rails_helper"

RSpec.describe "Leaderboard CSV export", type: :request do
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

  def build_active_competition(owner)
    competition = Competition.create!(
      name: "Leaderboard Export Comp #{SecureRandom.hex(3)}",
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

  it "returns CSV with leaderboard stats for the competition owner" do
    host = create_user(name: "Host", username_prefix: "host", email_prefix: "host")
    competitor = create_user(name: "Competitor", username_prefix: "competitor", email_prefix: "competitor")
    competition = build_active_competition(host)
    Enrollment.create!(user: competitor, competition: competition)
    Attempt.create!(user: competitor, climb: competition.climbs.first, attempt_count: 1)

    sign_in_as(host)
    get leaderboard_export_competition_path(competition, format: :csv)

    expect(response).to have_http_status(:ok)
    expect(response.media_type).to eq("text/csv")
    expect(response.body).to include("Rank,Name,Username,Email,Points,Total Attempts")
    expect(response.body).to include(competitor.email_address)
    expect(response.body).to include("Climb A (Points)")
    expect(response.body).to include("Sent")
  end

  it "forbids non-owners from downloading the CSV" do
    host = create_user(name: "Host", username_prefix: "host", email_prefix: "host")
    competitor = create_user(name: "Competitor", username_prefix: "competitor", email_prefix: "competitor")
    competition = build_active_competition(host)
    Enrollment.create!(user: competitor, competition: competition)

    sign_in_as(competitor)
    get leaderboard_export_competition_path(competition, format: :csv)

    expect(response).to have_http_status(:forbidden)
  end

  it "redirects guests to sign in" do
    host = create_user(name: "Host", username_prefix: "host", email_prefix: "host")
    competition = build_active_competition(host)

    get leaderboard_export_competition_path(competition, format: :csv)

    expect(response).to redirect_to(new_session_path)
  end
end
