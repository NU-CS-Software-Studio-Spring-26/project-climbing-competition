class ClimbsController < ApplicationController
  def show
    @competition = Competition.find(params.expect(:competition_id))
    @climb = @competition.climbs.find(params.expect(:id))
    @attempt = if authenticated? && current_user.competitions.include?(@competition)
      current_user.attempts.find_or_initialize_by(climb: @climb)
    end
  end
end
