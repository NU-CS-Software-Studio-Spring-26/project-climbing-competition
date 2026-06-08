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
    assert_match competitions(:one).name, response.body
    assert_match competitions(:one).climb_grade_range_label, response.body
  end

  test "index filters competitions by climb grade range on cards" do
    climbs(:one).update!(grading: "V1")
    climbs(:one_two).update!(grading: "V8")
    climbs(:two).update!(grading: "V5")
    climbs(:two_two).update!(grading: "V7")

    get competitions_url, params: { grade_min: 4, grade_max: 8 }

    assert_response :success
    assert_no_match competitions(:one).name, response.body
    assert_match competitions(:two).name, response.body
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
          name: "Spring Send Fest",
          description: "Open event",
          send_points: 25,
          flash_points: 30,
          attempt_deduction: 5,
          climbs_attributes: {
            "0" => { name: "Climb 1", url: "https://kilterboard.com/climb/1", grading: "V4", hold_assignments: { "r1c1" => "purple", "r2c1" => "green" }.to_json },
            "1" => { name: "Climb 2", url: "https://kilterboard.com/climb/2", grading: "V6" }
          }
        }
      }
    end

    assert_redirected_to competition_url(Competition.last)
    assert_equal @user.id, Competition.last.owner_id
    assert_equal "intermediate", Competition.last.level
    assert_equal 4, Competition.last.v_grade_min
    assert_equal 6, Competition.last.v_grade_max
    assert_equal 2, Competition.last.climbs.count
    assert_equal({ "r1c1" => "purple", "r2c1" => "green" }, Competition.last.climbs.first.hold_assignments)
  end

  test "should redirect create when unauthenticated" do
    assert_no_difference("Competition.count") do
      post competitions_url, params: { competition: { starts_at: @competition.starts_at, ends_at: @competition.ends_at, name: "Blocked Event" } }
    end

    assert_redirected_to new_session_url
  end

  test "should re-render new with validation errors when competition is invalid" do
    sign_in_as(@user)

    assert_no_difference("Competition.count") do
      post competitions_url, params: {
        competition: {
          starts_at_date: Date.current.to_s,
          starts_at_time: "15:00",
          ends_at_date: Date.current.to_s,
          ends_at_time: "14:00",
          name: "",
          send_points: 0,
          flash_points: 0,
          attempt_deduction: -1,
          climbs_attributes: {
            "0" => { name: "Only Climb", url: "https://kilterboard.com/climb/1", grading: "V4" }
          }
        }
      }
    end

    assert_response :unprocessable_entity
    assert_match "Name can&#39;t be blank", response.body
    assert_match "Ends at must be after the start date and time", response.body
    assert_match "Competition must have at least 2 climbs", response.body
  end

  test "should show competition" do
    Attempt.create!(user: users(:one), climb: climbs(:one), attempt_count: 1)
    Attempt.create!(user: users(:two), climb: climbs(:one), attempt_count: 1)
    Attempt.create!(user: users(:two), climb: climbs(:one_two), attempt_count: 2, invalidated: true)

    get competition_url(@competition)
    assert_response :success
    assert_match "V2", response.body
    assert_match "V3", response.body
    assert_match "Scoring Rules", response.body
    assert_match "Leaderboard", response.body
    assert_operator response.body.index(users(:one).username), :<, response.body.index(users(:two).username)
  end

  test "should get edit when signed in as owner" do
    sign_in_as(@user)
    get edit_competition_url(@competition)
    assert_response :success
  end

  test "should redirect edit when unauthenticated" do
    get edit_competition_url(@competition)
    assert_redirected_to new_session_url
  end

  test "should not get edit when signed in as non-owner" do
    sign_in_as(users(:two))
    get edit_competition_url(@competition)
    assert_redirected_to competitions_url
    follow_redirect!
    assert_match(/only edit/i, flash[:alert].to_s)
  end

  test "should update competition when signed in as owner" do
    sign_in_as(@user)

    patch competition_url(@competition), params: {
      competition: {
        starts_at: @competition.starts_at,
        ends_at: @competition.ends_at,
        name: @competition.name,
        send_points: @competition.send_points,
        flash_points: @competition.flash_points,
        attempt_deduction: @competition.attempt_deduction,
        climbs_attributes: {
          @competition.climbs.first.id.to_s => { name: "Updated Climb", url: "https://kilterboard.com/climb/updated", grading: "V2" },
          @competition.climbs.last.id.to_s => { name: "Second Climb", url: "https://kilterboard.com/climb/second", grading: "V3" }
        }
      }
    }
    assert_redirected_to competition_url(@competition)
    @competition.reload
    assert_equal "V2–V3", @competition.climb_grade_range_label
  end

  test "should redirect update when unauthenticated" do
    patch competition_url(@competition), params: {
      competition: { name: "Hijacked Event" }
    }

    assert_redirected_to new_session_url
    @competition.reload
    assert_not_equal "Hijacked Event", @competition.name
  end

  test "should not update competition when signed in as non-owner" do
    sign_in_as(users(:two))

    patch competition_url(@competition), params: {
      competition: {
        starts_at: @competition.starts_at,
        ends_at: @competition.ends_at,
        name: "Hijacked Event",
        send_points: @competition.send_points,
        flash_points: @competition.flash_points,
        attempt_deduction: @competition.attempt_deduction,
        climbs_attributes: {
          @competition.climbs.first.id.to_s => { name: "Updated Climb", url: "https://kilterboard.com/climb/updated", grading: "V2" },
          @competition.climbs.last.id.to_s => { name: "Second Climb", url: "https://kilterboard.com/climb/second", grading: "V3" }
        }
      }
    }

    assert_redirected_to competitions_url
    @competition.reload
    assert_not_equal "Hijacked Event", @competition.name
  end

  test "should destroy competition when signed in as owner" do
    sign_in_as(@user)

    assert_difference("Competition.count", -1) do
      delete competition_url(@competition)
    end

    assert_redirected_to competitions_url
  end

  test "should return to user profile after deleting from profile page" do
    sign_in_as(@user)

    assert_difference("Competition.count", -1) do
      delete competition_url(@competition), params: { return_to: user_path(@user) }
    end

    assert_redirected_to user_url(@user)
  end

  test "should redirect destroy when unauthenticated" do
    assert_no_difference("Competition.count") do
      delete competition_url(@competition)
    end

    assert_redirected_to new_session_url
  end

  test "should not destroy competition when signed in as non-owner" do
    sign_in_as(users(:two))

    assert_no_difference("Competition.count") do
      delete competition_url(@competition)
    end

    assert_redirected_to competitions_url
    follow_redirect!
    assert_match(/only delete/i, flash[:alert].to_s)
  end
end
