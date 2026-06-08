require "rails_helper"

RSpec.describe "Video submission review", type: :request do
  it "allows a host to review climb videos and mark a send invalid" do
    skip("Implement once host review routes/controllers are added for attempt video validation")
  end

  it "prevents non-host users from reviewing other climbers' submissions" do
    skip("Implement once host review authorization is added")
  end
end
