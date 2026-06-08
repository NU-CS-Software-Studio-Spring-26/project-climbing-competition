require "rails_helper"

RSpec.describe "Password resets", type: :request do
  include ActiveJob::TestHelper

  before do
    clear_enqueued_jobs
  end

  it "returns the same generic message for unknown emails" do
    expect do
      post password_resets_path, params: {
        password_reset: { email_address: "missing@example.com" }
      }
    end.not_to have_enqueued_job(ActionMailer::MailDeliveryJob)

    expect(response).to redirect_to(new_session_path)
    follow_redirect!
    expect(response.body).to include("If that email is registered with a password account")
  end

  it "enqueues a reset email for a password user" do
    user = User.create!(
      name: "Reset Request User",
      username: "reset_request_user",
      email_address: "reset_request_user@example.com",
      password: "password123",
      password_confirmation: "password123"
    )

    expect do
      post password_resets_path, params: {
        password_reset: { email_address: user.email_address }
      }
    end.to have_enqueued_job(ActionMailer::MailDeliveryJob)

    expect(response).to redirect_to(new_session_path)
  end
end
