require "test_helper"

class ClimbTest < ActiveSupport::TestCase
  test "rejects climb urls longer than the allowed length" do
    climb = Climb.new(
      name: "Test Climb",
      url: "https://example.com/#{'a' * (Climb::URL_MAX_LENGTH + 1)}"
    )

    assert_not climb.valid?
    assert_includes climb.errors[:url], "is too long (maximum is #{Climb::URL_MAX_LENGTH} characters)"
  end
end
