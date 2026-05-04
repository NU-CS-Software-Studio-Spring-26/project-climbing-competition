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
    assert_match competitions(:one).level.titleize, response.body
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
          starts_at: @competition.starts_at,
          ends_at: @competition.ends_at,
          level: "intermediate",
          name: "Spring Send Fest",
          description: "Open event",
          climbs_attributes: {
            "0" => { name: "Climb 1", url: "https://kilterboard.com/climb/1" },
            "1" => { name: "Climb 2", url: "https://kilterboard.com/climb/2" }
          }
        }
      }
    end

    assert_redirected_to competition_url(Competition.last)
    assert_equal @user.id, Competition.last.owner_id
    assert_equal "intermediate", Competition.last.level
    assert_equal 2, Competition.last.climbs.count
  end

  test "should redirect create when unauthenticated" do
    assert_no_difference("Competition.count") do
      post competitions_url, params: { competition: { starts_at: @competition.starts_at, ends_at: @competition.ends_at, name: "Blocked Event" } }
    end

    assert_redirected_to new_session_url
  end

  test "should show competition" do
    Enrollment.create!(user: users(:one), competition: @competition)
    Enrollment.create!(user: users(:two), competition: @competition)

    Attempt.create!(user: users(:one), climb: climbs(:one), attempt_count: 1, completed: true)
    Attempt.create!(user: users(:two), climb: climbs(:one), attempt_count: 1, completed: true)
    Attempt.create!(user: users(:two), climb: climbs(:one_two), attempt_count: 2, completed: false)

    get competition_url(@competition)
    assert_response :success
    assert_match @competition.level.titleize, response.body
    assert_match "Leaderboard", response.body
    assert_operator response.body.index(users(:one).username), :<, response.body.index(users(:two).username)
  end

  test "should get edit" do
    get edit_competition_url(@competition)
    assert_response :success
  end

  test "should update competition" do
    patch competition_url(@competition), params: {
      competition: {
        starts_at: @competition.starts_at,
        ends_at: @competition.ends_at,
        level: @competition.level,
        name: @competition.name,
        climbs_attributes: {
          @competition.climbs.first.id.to_s => { name: "Updated Climb", url: "https://kilterboard.com/climb/updated" },
          @competition.climbs.last.id.to_s => { name: "Second Climb", url: "https://kilterboard.com/climb/second" }
        }
      }
    }
    assert_redirected_to competition_url(@competition)
  end

  test "should destroy competition" do
    assert_difference("Competition.count", -1) do
      delete competition_url(@competition)
    end

    assert_redirected_to competitions_url
  end
end
