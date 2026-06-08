Given("a competition host exists for leaderboard export") do
  @host = User.create!(
    name: "Leaderboard Host",
    username: "lb_host_#{SecureRandom.hex(4)}",
    email_address: "lb_host_#{SecureRandom.hex(4)}@example.com",
    password: "password123",
    password_confirmation: "password123"
  )
end

Given("an active competition with enrolled competitors exists") do
  @competition = Competition.create!(
    name: "Leaderboard Export Comp",
    starts_at: 1.week.from_now,
    ends_at: 2.weeks.from_now,
    flash_points: 30,
    attempt_deduction: 5,
    owner: @host,
    climbs_attributes: {
      "0" => { name: "Climb A", url: "https://example.com/a", grading: "V2" },
      "1" => { name: "Climb B", url: "https://example.com/b", grading: "V3" }
    }
  )
  @competition.update_columns(starts_at: 1.day.ago, ends_at: 1.day.from_now)
  @competition.reload

  @competitor = User.create!(
    name: "Leaderboard Competitor",
    username: "lb_comp_#{SecureRandom.hex(4)}",
    email_address: "lb_comp_#{SecureRandom.hex(4)}@example.com",
    password: "password123",
    password_confirmation: "password123"
  )
  Enrollment.create!(user: @competitor, competition: @competition)
end

Given("competitors have logged attempts on the competition") do
  climb = @competition.climbs.first
  Attempt.create!(user: @competitor, climb: climb, attempt_count: 1)
end

Given("the host is signed in for leaderboard export") do
  page.driver.submit(:post, session_path, {
    session: { email_address: @host.email_address, password: "password123" }
  })
end

Given("a non-owner is signed in for leaderboard export") do
  page.driver.submit(:post, session_path, {
    session: { email_address: @competitor.email_address, password: "password123" }
  })
end

When("the host downloads the leaderboard CSV") do
  page.driver.get leaderboard_export_competition_path(@competition, format: :csv)
  @last_response = page.driver.response
end

When("the host visits the competition page for leaderboard export") do
  visit competition_path(@competition)
end

When("the non-owner requests the leaderboard CSV") do
  page.driver.get leaderboard_export_competition_path(@competition, format: :csv)
  @last_response = page.driver.response
end

When("a guest requests the leaderboard CSV") do
  page.driver.get leaderboard_export_competition_path(@competition, format: :csv)
  @last_response = page.driver.response
end

Then("the CSV should include competitor rankings and per-climb stats") do
  expect(@last_response.status).to eq(200)
  expect(@last_response.headers["Content-Type"]).to include("text/csv")
  expect(@last_response.body).to include("Rank,Name,Username,Email,Points,Total Attempts")
  expect(@last_response.body).to include(@competitor.email_address)
  expect(@last_response.body).to include("Climb A (Grade)")
  expect(@last_response.body).to include("Sent")
end

Then("the host should see the export leaderboard link") do
  expect(page).to have_link("Export leaderboard CSV")
end

Then("the export should be forbidden") do
  expect(@last_response.status).to eq(403)
end

Then("the guest should be redirected to sign in") do
  expect(@last_response.status).to be_between(300, 399)
  expect(@last_response.headers["Location"]).to include(new_session_path)
end
