class ClimbsController < ApplicationController
  def show
    @competition = Competition.find(params.expect(:competition_id))
    @climb_id = params.expect(:id)
  end
end
