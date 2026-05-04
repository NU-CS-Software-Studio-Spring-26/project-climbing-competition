class EnrollmentsController < ApplicationController
  before_action :require_authentication
  before_action :set_competition

  def create
    @enrollment = @competition.enrollments.build(user: current_user)

    if @enrollment.save
      redirect_to @competition, notice: "You have joined the competition!"
    else
      redirect_to @competition, alert: "Could not join the competition."
    end
  end

  def destroy
    @enrollment = @competition.enrollments.find_by(user: current_user)
    @enrollment&.destroy
    redirect_to @competition, notice: "You have left the competition."
  end

  private

  def set_competition
    @competition = Competition.find(params[:competition_id])
  end
end
