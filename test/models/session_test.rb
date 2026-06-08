require "test_helper"

class SessionTest < ActiveSupport::TestCase
  test "rejects excessively long ip addresses" do
    session = Session.new(
      user: users(:one),
      ip_address: "1" * (Session::IP_ADDRESS_MAX_LENGTH + 1)
    )

    assert_not session.valid?
    assert_includes session.errors[:ip_address], "is too long (maximum is #{Session::IP_ADDRESS_MAX_LENGTH} characters)"
  end

  test "rejects excessively long user agents" do
    session = Session.new(
      user: users(:one),
      user_agent: "a" * (Session::USER_AGENT_MAX_LENGTH + 1)
    )

    assert_not session.valid?
    assert_includes session.errors[:user_agent], "is too long (maximum is #{Session::USER_AGENT_MAX_LENGTH} characters)"
  end
end
