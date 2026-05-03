class CompetitionsController < ApplicationController
  before_action :require_authentication, only: %i[ new create ]
  before_action :set_competition, only: %i[ show edit update destroy ]

  # GET /competitions or /competitions.json
  def index
    @competitions = Competition.includes(:owner, :users)
  end

  # GET /competitions/1 or /competitions/1.json
  def show
  end

  # GET /competitions/new
  def new
    @competition = Competition.new
    3.times { @competition.climbs.build }
  end

  # GET /competitions/1/edit
  def edit
    # Ensure at least one blank climb field for adding
    @competition.climbs.build if @competition.climbs.empty?
  end

  # POST /competitions or /competitions.json
  def create
    @competition = Competition.new(competition_params)
    @competition.owner = current_user

    respond_to do |format|
      if @competition.save
        format.html { redirect_to @competition, notice: "Competition was successfully created." }
        format.json { render :show, status: :created, location: @competition }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @competition.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /competitions/1 or /competitions/1.json
  def update
    respond_to do |format|
      if @competition.update(competition_params)
        format.html { redirect_to @competition, notice: "Competition was successfully updated.", status: :see_other }
        format.json { render :show, status: :ok, location: @competition }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @competition.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /competitions/1 or /competitions/1.json
  def destroy
    @competition.destroy!

    respond_to do |format|
      format.html { redirect_to competitions_path, notice: "Competition was successfully destroyed.", status: :see_other }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_competition
      @competition = Competition.find(params.expect(:id))
    end

    # Only allow a list of trusted parameters through.
    def competition_params
      params.require(:competition).permit(:name, :date, :level, :description, climbs_attributes: [:id, :name, :url, :_destroy])
    end
end
