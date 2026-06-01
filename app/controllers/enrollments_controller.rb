class EnrollmentsController < ApplicationController
  before_action :require_authentication
  before_action :set_competition

  def create
    unless @competition.joinable?
      redirect_to @competition, alert: "This competition has ended and is no longer open for joining."
      return
    end

    @enrollment = @competition.enrollments.build(user: current_user)

    if @enrollment.save
      redirect_to @competition, notice: "You have joined the competition!"
    else
      redirect_to @competition, alert: "Could not join the competition."
    end
  end

  def destroy
    unless @competition.leavable?
      redirect_to @competition, alert: "This competition has ended. You can no longer leave it."
      return
    end

    @enrollment = @competition.enrollments.find_by(user: current_user)

    if @enrollment&.destroy
      redirect_to @competition, notice: "You have left the competition."
    else
      redirect_to @competition, alert: "Could not leave the competition."
    end
  end

  private

  def set_competition
    @competition = Competition.find(params[:competition_id])
  end
end
