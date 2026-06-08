class AttemptsController < ApplicationController
  before_action :require_authentication
  before_action :set_competition
  before_action :set_climb
  before_action :ensure_enrolled, only: %i[ create update ]
  before_action :set_attempt, only: %i[ review ]
  before_action :ensure_competition_owner, only: %i[ review ]

  def create
    save_attempt
  end

  def update
    save_attempt
  end

  def review
    @attempt.assign_attributes(review_params)

    if @attempt.save
      redirect_to competition_path(@competition), notice: "Submission review was updated."
    else
      redirect_to competition_path(@competition), alert: @attempt.errors.full_messages.to_sentence
    end
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

  def set_attempt
    @attempt = @climb.attempts.find(params.expect(:id))
  end

  def ensure_competition_owner
    return if current_user == @competition.owner

    redirect_to competition_path(@competition), alert: "Only the competition creator can review submissions."
  end

  def attempt_params
    params.expect(attempt: [ :attempt_count, :completed, :submission_video ])
  end

  def review_params
    status = params.expect(attempt: [ :review_status ])[:review_status]
    { review_status: status }
  end
end
