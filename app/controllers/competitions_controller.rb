class CompetitionsController < ApplicationController
  before_action :require_authentication, only: %i[ new create destroy ]
  before_action :set_competition, only: %i[ show edit update destroy ]

  # GET /competitions or /competitions.json
  def index
    @competitions = Competition.includes(:owner, :users)

    # Handle sorting and filtering
    @sort_by = params[:sort_by]
    @sort_direction = params[:sort_direction] || "asc"
    @selected_levels = Array(params[:level]).reject(&:blank?)

    # Apply level filters if selected (multiple levels allowed)
    @competitions = @competitions.where(level: @selected_levels) if @selected_levels.present?

    # Apply sorting only if sort_by is specified
    case @sort_by
    when "starts_at"
      @competitions = @competitions.order(starts_at: @sort_direction.to_sym)
    when "ends_at"
      @competitions = @competitions.order(ends_at: @sort_direction.to_sym)
    end

    # Apply pagination
    @competitions = @competitions.page(params[:page]).per(9)
  end
  # GET /competitions/1 or /competitions/1.json
  def show
    @leaderboard_entries = @competition.leaderboard_entries

    if authenticated?
      @user_attempts_by_climb_id = current_user.attempts.where(climb: @competition.climbs).index_by(&:climb_id)
    else
      @user_attempts_by_climb_id = {}
    end

    # Preload all attempts for modal data
    @attempts_by_user_and_climb = {}
    @competition.attempts.includes(:user, :climb).each do |attempt|
      @attempts_by_user_and_climb[attempt.user_id] ||= {}
      @attempts_by_user_and_climb[attempt.user_id][attempt.climb_id] = attempt
    end
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
    assign_combined_datetimes(@competition)

    respond_to do |format|
      if @competition.save
        format.html { redirect_to @competition, notice: "Competition was successfully created." }
        format.json { render :show, status: :created, location: @competition }
      else
        ensure_minimum_climb_fields(@competition)
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @competition.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /competitions/1 or /competitions/1.json
  def update
    @competition.assign_attributes(competition_params)
    assign_combined_datetimes(@competition)
    respond_to do |format|
      if @competition.save
        format.html { redirect_to @competition, notice: "Competition was successfully updated.", status: :see_other }
        format.json { render :show, status: :ok, location: @competition }
      else
        ensure_minimum_climb_fields(@competition)
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @competition.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /competitions/1 or /competitions/1.json
  def destroy
    unless @competition.owner_id.present? && current_user == @competition.owner
      respond_to do |format|
        format.html { redirect_to competitions_path, alert: "You can only delete competitions you created.", status: :see_other }
        format.json { head :forbidden }
      end
      return
    end

    @competition.destroy!

    respond_to do |format|
      format.html { redirect_to destroy_return_path, notice: "Competition was successfully deleted.", status: :see_other }
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
      params.require(:competition).permit(:name, :date, :starts_at, :ends_at, :level, :description, :send_points, :flash_points, :attempt_deduction, climbs_attributes: [ :id, :name, :url, :grading, :_destroy ])
    end
    def assign_combined_datetimes(competition)
      raw = params.require(:competition).permit(:starts_at_date, :starts_at_time, :ends_at_date, :ends_at_time)
      competition.starts_at = combine_date_and_time(raw[:starts_at_date], raw[:starts_at_time]) if raw.key?(:starts_at_date) || raw.key?(:starts_at_time)
      competition.ends_at = combine_date_and_time(raw[:ends_at_date], raw[:ends_at_time]) if raw.key?(:ends_at_date) || raw.key?(:ends_at_time)
    end

    def combine_date_and_time(date, time)
      return nil if date.blank?

      Time.zone.parse("#{date} #{time.presence || '00:00'}")
    end

    def ensure_minimum_climb_fields(competition)
      (2 - competition.climbs.size).times { competition.climbs.build } if competition.climbs.size < 2
    end

    def destroy_return_path
      return competitions_path unless params[:return_to].present?

      return_to = params[:return_to].to_s
      return competitions_path unless return_to.start_with?("/") && !return_to.start_with?("//")

      return_to
    end
end
