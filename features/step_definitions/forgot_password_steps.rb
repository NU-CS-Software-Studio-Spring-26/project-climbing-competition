Given("a password user exists for forgot password") do
  @forgot_password_user = User.create!(
    name: "Forgot Password User",
    username: "forgot_password_user",
    email_address: "forgot_password_user@example.com",
    password: "password123",
    password_confirmation: "password123"
  )
end

Given("I am on the forgot password page") do
  visit new_password_reset_path
end

When("I request a password reset for that user from the sign in page") do
  visit new_session_path
  click_link "Forgot password?"
  fill_in "Email address", with: @forgot_password_user.email_address
  click_button "Send reset link"
end

When("I submit a forgot password request for an unknown email") do
  fill_in "Email address", with: "unknown-reset-user@example.com"
  click_button "Send reset link"
end

Then("I should see the generic password reset confirmation") do
  expect(page).to have_current_path(new_session_path)
  expect(page).to have_content(
    "If that email is registered with a password account, you will receive reset instructions shortly."
  )
end
