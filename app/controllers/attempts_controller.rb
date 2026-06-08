class AttemptsController < ApplicationController
  before_action :require_authentication
  before_action :set_competition
  before_action :set_climb
  before_action :ensure_enrolled, only: %i[ create update ]
  before_action :ensure_competition_started, only: %i[ create update ]
  before_action :set_attempt, only: %i[ invalidate ]
  before_action :ensure_competition_owner, only: %i[ invalidate video_reviews ]

  def create
    save_attempt
  end

  def update
    save_attempt
  end

  def invalidate
    if @attempt.update(invalidated: true)
      redirect_to competition_climb_video_reviews_path(@competition, @climb, index: params[:index]), notice: "Send invalidated. Points are now 0 for this climb."
    else
      redirect_to competition_climb_video_reviews_path(@competition, @climb, index: params[:index]), alert: @attempt.errors.full_messages.to_sentence
    end
  end

  def video_reviews
    @video_attempts = @climb.attempts
      .includes(:user, submission_video_attachment: :blob)
      .select { |attempt| attempt.submission_video.attached? }

    if @video_attempts.empty?
      redirect_to competition_path(@competition), alert: "No video submissions for this climb yet."
      return
    end

    @current_index = params[:index].to_i
    @current_index = 0 if @current_index.negative?
    @current_index = @video_attempts.length - 1 if @current_index >= @video_attempts.length

    @attempt = @video_attempts[@current_index]
    @previous_index = @current_index.positive? ? @current_index - 1 : nil
    @next_index = @current_index < (@video_attempts.length - 1) ? @current_index + 1 : nil
  end

  private

  def save_attempt
    @attempt = current_user.attempts.find_or_initialize_by(climb: @climb)
    @attempt.assign_attributes(attempt_params)
    attach_uploaded_video

    if @attempt.save
      redirect_to competition_path(@competition), notice: "Your send was saved."
    else
      redirect_to competition_path(@competition), alert: @attempt.errors.full_messages.to_sentence
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

  def ensure_competition_started
    return if @competition.started?

    redirect_to competition_path(@competition), alert: "Climbs are not available until the competition starts."
  end

  def set_attempt
    @attempt = @climb.attempts.find(params.expect(:id))
  end

  def ensure_competition_owner
    return if current_user == @competition.owner

    redirect_to competition_path(@competition), alert: "Only the competition creator can review submissions."
  end

  def attempt_params
    params.expect(attempt: [ :attempt_count ])
  end

  def attach_uploaded_video
    uploaded_video = params.dig(:attempt, :submission_video)
    return if uploaded_video.blank?

    @attempt.submission_video.attach(uploaded_video)
  end
end
