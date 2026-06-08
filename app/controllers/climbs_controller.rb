class ClimbsController < ApplicationController
  def show
    @competition = Competition.find(params.expect(:competition_id))
    unless @competition.climbs_visible_to?(authenticated? ? current_user : nil)
      redirect_to competition_path(@competition), alert: "Climbs are not available until the competition starts."
      return
    end

    @climb = @competition.climbs.find(params.expect(:id))
    @attempt = if authenticated? && current_user.competitions.include?(@competition)
      current_user.attempts.find_or_initialize_by(climb: @climb)
    end
  end
end
