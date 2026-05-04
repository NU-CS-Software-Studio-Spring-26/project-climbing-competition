class AttemptsController < ApplicationController
  before_action :require_authentication
  before_action :set_competition
  before_action :set_climb
  before_action :ensure_enrolled

  def create
    save_attempt
  end

  def update
    save_attempt
  end

  private

  def save_attempt
    @attempt = current_user.attempts.find_or_initialize_by(climb: @climb)
    @attempt.assign_attributes(attempt_params)

    if @attempt.save
      redirect_to competition_climb_path(@competition, @climb), notice: "Your attempt was saved."
    else
      render "climbs/show", status: :unprocessable_entity
    end
  end

  def set_competition
    @competition = Competition.find(params.expect(:competition_id))
  end

  def set_climb
    @climb = @competition.climbs.find(params.expect(:climb_id))
  end

  def ensure_enrolled
    return if current_user.competitions.include?(@competition)

    redirect_to competition_path(@competition), alert: "Join the competition before logging attempts."
  end

  def attempt_params
    params.expect(attempt: [ :attempt_count, :completed ])
  end
end
