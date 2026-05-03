require "test_helper"

class CompetitionsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @competition = competitions(:one)
    @user = users(:one)
  end

  def sign_in_as(user)
    post session_url, params: { session: { email_address: user.email_address, password: "password123" } }
  end

  test "should get index" do
    get competitions_url
    assert_response :success
  end

  test "should get new" do
    sign_in_as(@user)
    get new_competition_url
    assert_response :success
  end

  test "should redirect new when unauthenticated" do
    get new_competition_url
    assert_redirected_to new_session_url
  end

  test "should create competition" do
    sign_in_as(@user)

    assert_difference("Competition.count") do
      post competitions_url, params: {
        competition: {
          date: @competition.date,
          name: "Spring Send Fest",
          description: "Open event",
          owner_id: users(:two).id
        }
      }
    end

    assert_redirected_to competition_url(Competition.last)
    assert_equal @user.id, Competition.last.owner_id
  end

  test "should redirect create when unauthenticated" do
    assert_no_difference("Competition.count") do
      post competitions_url, params: { competition: { date: @competition.date, name: "Blocked Event" } }
    end

    assert_redirected_to new_session_url
  end

  test "should show competition" do
    get competition_url(@competition)
    assert_response :success
  end

  test "should get edit" do
    get edit_competition_url(@competition)
    assert_response :success
  end

  test "should update competition" do
    patch competition_url(@competition), params: { competition: { date: @competition.date, name: @competition.name } }
    assert_redirected_to competition_url(@competition)
  end

  test "should destroy competition" do
    assert_difference("Competition.count", -1) do
      delete competition_url(@competition)
    end

    assert_redirected_to competitions_url
  end
end
