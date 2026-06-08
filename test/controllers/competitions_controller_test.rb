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
    Attempt.create!(user: users(:one), climb: climbs(:one), attempt_count: 1, completed: true)
    Attempt.create!(user: users(:two), climb: climbs(:one), attempt_count: 1, completed: true)
    Attempt.create!(user: users(:two), climb: climbs(:one_two), attempt_count: 2, completed: false)

    get competition_url(@competition)
    assert_response :success
    assert_match "V2", response.body
    assert_match "V3", response.body
    assert_match "Scoring Rules", response.body
    assert_match "Leaderboard", response.body
    assert_operator response.body.index(users(:one).username), :<, response.body.index(users(:two).username)
  end

  test "should show join link to sign up for unauthenticated users on joinable competition" do
    @competition.update!(starts_at: 1.day.from_now, ends_at: 1.week.from_now)

    get competition_url(@competition)

    assert_response :success
    assert_select "a.btn-join-competition-show[href='#{new_user_path}']", text: "JOIN"
    assert_select "form[action='#{competition_enrollments_path(@competition)}'] input[value='JOIN']", count: 0
  end

  test "should get edit when signed in as owner" do
    sign_in_as(@user)
    get edit_competition_url(@competition)
    assert_response :success
    assert_match @competition.locked_grade_range_label, response.body
    assert_match "New climbs must use grades within", response.body
  end

  test "should redirect edit when unauthenticated" do
    get edit_competition_url(@competition)
    assert_redirected_to new_session_url
  end

  test "should not get edit when signed in as non-owner" do
    sign_in_as(users(:two))
    get edit_competition_url(@competition)
    assert_redirected_to competition_url(@competition)
    follow_redirect!
    assert_match(/only edit/i, flash[:alert].to_s)
  end

  test "should show edit link for owner on competition page" do
    sign_in_as(@user)
    get competition_url(@competition)
    assert_response :success
    assert_select "a.btn-competition-edit", text: "Edit competition"
  end

  test "should update competition when signed in as owner" do
    sign_in_as(@user)

    patch competition_url(@competition), params: {
      competition: {
        name: "Updated Spring Bash",
        starts_at_date: "2026-05-16",
        starts_at_time: "10:00",
        ends_at_date: "2026-05-16",
        ends_at_time: "18:00"
      }
    }

    assert_redirected_to competition_url(@competition)
    @competition.reload
    assert_equal "Updated Spring Bash", @competition.name
    assert_equal 0, @competition.v_grade_min
    assert_equal 3, @competition.v_grade_max
  end

  test "should add climb within locked grade range" do
    sign_in_as(@user)

    assert_difference("@competition.climbs.count", 1) do
      patch competition_url(@competition), params: {
        competition: {
          name: @competition.name,
          starts_at_date: @competition.starts_at.to_date.to_s,
          starts_at_time: @competition.starts_at.strftime("%H:%M"),
          ends_at_date: @competition.ends_at.to_date.to_s,
          ends_at_time: @competition.ends_at.strftime("%H:%M"),
          climbs_attributes: {
            "0" => { name: "New Beginner Climb", url: "https://kilterboard.com/climb/new", grading: "V1" }
          }
        }
      }
    end

    assert_redirected_to competition_url(@competition)
    assert_equal "V1", @competition.climbs.order(:id).last.grading
  end

  test "should reject new climb outside locked grade range" do
    sign_in_as(@user)

    assert_no_difference("@competition.climbs.count") do
      patch competition_url(@competition), params: {
        competition: {
          name: @competition.name,
          starts_at_date: @competition.starts_at.to_date.to_s,
          starts_at_time: @competition.starts_at.strftime("%H:%M"),
          ends_at_date: @competition.ends_at.to_date.to_s,
          ends_at_time: @competition.ends_at.strftime("%H:%M"),
          climbs_attributes: {
            "0" => { name: "Too Hard", url: "https://kilterboard.com/climb/hard", grading: "V8" }
          }
        }
      }
    end

    assert_response :unprocessable_entity
    assert_match "New climbs must use grades within", response.body
  end

  test "should redirect update when signed in as non-owner" do
    sign_in_as(users(:two))

    patch competition_url(@competition), params: {
      competition: { name: "Hijacked Name" }
    }

    assert_redirected_to competition_url(@competition)
    assert_equal "Spring Boulder Bash", @competition.reload.name
  end

  test "should redirect update when unauthenticated" do
    patch competition_url(@competition), params: {
      competition: { name: "Hijacked Event" }
    }

    assert_redirected_to new_session_url
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

    assert_redirected_to competition_url(@competition)
    follow_redirect!
    assert_match(/only edit competitions you created/i, flash[:alert].to_s)
  end
end
