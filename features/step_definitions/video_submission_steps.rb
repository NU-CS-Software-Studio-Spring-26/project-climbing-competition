Given("a competition host exists") do
  @host = User.create!(
    name: "Host User",
    username: "host_#{SecureRandom.hex(4)}",
    email_address: "host_#{SecureRandom.hex(4)}@example.com",
    password: "password123",
    password_confirmation: "password123"
  )
end

Given("a competition with at least two climbs exists") do
  @competition = Competition.create!(
    name: "Video Submission Comp",
    starts_at: 1.day.ago,
    ends_at: 1.day.from_now,
    flash_points: 30,
    attempt_deduction: 5,
    owner: @host,
    climbs_attributes: {
      "0" => { name: "Climb A", url: "https://example.com/a", grading: "V2" },
      "1" => { name: "Climb B", url: "https://example.com/b", grading: "V3" }
    }
  )
  @climb = @competition.climbs.first
end

Given("video submissions are required for the competition") do
  @competition.update!(video_submissions_required: true)
end

Given("a competitor is enrolled in the competition") do
  @competitor = User.create!(
    name: "Competitor User",
    username: "competitor_#{SecureRandom.hex(4)}",
    email_address: "competitor_#{SecureRandom.hex(4)}@example.com",
    password: "password123",
    password_confirmation: "password123"
  )
  Enrollment.create!(user: @competitor, competition: @competition)
end

When("the competitor submits a completed send with an attached video") do
  page.driver.submit(:post, session_path, { session: { email_address: @competitor.email_address, password: "password123" } })

  temp_path = Rails.root.join("tmp", "cucumber_submission_video.mp4")
  File.binwrite(temp_path, "fake-video-content")
  uploaded_video = Rack::Test::UploadedFile.new(temp_path, "video/mp4")

  page.driver.submit(:post, competition_climb_attempt_path(@competition, @climb), {
    attempt: {
      attempt_count: 1,
      submission_video: uploaded_video
    }
  })

  @last_response = page.driver.response
end

Then("the competitor should see a successful save message") do
  if @last_response.status.between?(300, 399)
    redirected_path = URI.parse(@last_response.headers.fetch("Location")).path
    visit redirected_path
    expect(page.body).to include("Your send was saved.")
  else
    expect(@last_response.status).to eq(200)
    expect(@last_response.body).to include("Your send was saved.")
  end
end

Then("the competitor should receive points immediately") do
  attempt = Attempt.find_by!(user: @competitor, climb: @climb)
  expect(attempt.points_awarded).to be > 0
end

Given("a competitor has a scored completed send with an uploaded video") do
  step "video submissions are required for the competition"
  step "a competitor is enrolled in the competition"

  temp_path = Rails.root.join("tmp", "cucumber_submission_video.mp4")
  File.binwrite(temp_path, "fake-video-content")

  attempt = Attempt.create!(user: @competitor, climb: @climb, attempt_count: 1)
  attempt.submission_video.attach(
    io: File.open(temp_path, "rb"),
    filename: "cucumber_submission_video.mp4",
    content_type: "video/mp4"
  )
  @attempt = attempt
end

When("the host marks that submission as invalid") do
  page.driver.submit(:post, session_path, { session: { email_address: @host.email_address, password: "password123" } })
  page.driver.submit(:patch, invalidate_competition_climb_attempt_path(@competition, @climb, @attempt), { index: 0 })
  @last_response = page.driver.response
  @attempt.reload
end

Then("the competitor's points for that climb should become 0") do
  expect(@attempt.invalidated?).to be(true)
  expect(@attempt.points_awarded).to eq(0)
end

Then("the leaderboard should reflect the updated score") do
  competitor_entry = @competition.leaderboard_entries.find { |entry| entry.user.id == @competitor.id }
  expect(competitor_entry.points).to eq(0)
end
