require "test_helper"

class ClimbTest < ActiveSupport::TestCase
  test "rejects profane climb names" do
    climb = Climb.new(
      competition: competitions(:one),
      name: "Hell Hard Problem",
      url: "https://www.boardsesh.com/route/hell-hard",
      grading: "V4"
    )

    assert_not climb.valid?
    assert_includes climb.errors[:name], "contains inappropriate language"
  end

  test "accepts a boardsesh URL with www subdomain" do
    climb = Climb.new(
      competition: competitions(:one),
      name: "Boardsesh Route",
      url: "https://www.boardsesh.com/route/123",
      grading: "V4"
    )

    assert climb.valid?
  end

  test "rejects a boardsesh URL without www subdomain" do
    climb = Climb.new(
      competition: competitions(:one),
      name: "Boardsesh Route",
      url: "https://boardsesh.com/route/123",
      grading: "V4"
    )

    assert_not climb.valid?
    assert_includes climb.errors[:url], "must be a link from www.boardsesh.com or portal.kiltergrips.com"
  end

  test "accepts a kiltergrips URL with portal subdomain" do
    climb = Climb.new(
      competition: competitions(:one),
      name: "Kilter Route",
      url: "https://portal.kiltergrips.com/search/climbs?angle=40&climbUuid=123",
      grading: "V4"
    )

    assert climb.valid?
  end

  test "rejects a kiltergrips URL without portal subdomain" do
    climb = Climb.new(
      competition: competitions(:one),
      name: "Kilter Route",
      url: "https://kiltergrips.com/beta/route/123",
      grading: "V4"
    )

    assert_not climb.valid?
    assert_includes climb.errors[:url], "must be a link from www.boardsesh.com or portal.kiltergrips.com"
  end

  test "rejects climb urls longer than the allowed length" do
    climb = Climb.new(
      competition: competitions(:one),
      name: "Test Climb",
      url: "https://www.boardsesh.com/#{'a' * (Climb::URL_MAX_LENGTH + 1)}",
      grading: "V4"
    )

    assert_not climb.valid?
    assert_includes climb.errors[:url], "is too long (maximum is #{Climb::URL_MAX_LENGTH} characters)"
  end

  test "sanitizes hold assignments to supported colors and hold ids" do
    climb = Climb.new(
      competition: competitions(:one),
      name: "Visual Route",
      url: "https://www.boardsesh.com/route/visual",
      grading: "V5",
      hold_assignments: {
        "r1c1" => "purple",
        "r2c9" => "GREEN",
        "invalid" => "blue",
        "r3c2" => "orange"
      }
    )

    assert climb.valid?
    assert_equal({ "r1c1" => "purple", "r2c9" => "green" }, climb.hold_assignments)
  end

  test "rejects excessive hold assignments" do
    assignments = {}
    (Climb::MAX_HOLD_ASSIGNMENTS + 1).times do |index|
      assignments["r#{index}c0"] = "purple"
    end

    climb = Climb.new(
      competition: competitions(:one),
      name: "Too Many Holds",
      url: "https://www.boardsesh.com/massive",
      grading: "V6",
      hold_assignments: assignments
    )

    assert_not climb.valid?
    assert_includes climb.errors[:hold_assignments], "has too many selected holds"
  end
end
