class UsersController < ApplicationController
  before_action :require_authentication, only: %i[ show edit update ]
  before_action :set_user, only: %i[ show edit update ]

  # GET /users/1 or /users/1.json
  def show
  end

  # GET /users/new
  def new
    @user = User.new
  end

  # GET /users/1/edit
  def edit
  end

  # POST /users or /users.json
  def create
    @user = User.new(user_params)

    respond_to do |format|
      if @user.save
        terminate_session
        start_new_session_for(@user)
        format.html { redirect_to @user, notice: "Profile was successfully created." }
        format.json { render :show, status: :created, location: @user }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @user.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /users/1 or /users/1.json
  def update
    respond_to do |format|
      if @user.update(user_params)
        format.html { redirect_to @user, notice: "User was successfully updated.", status: :see_other }
        format.json { render :show, status: :ok, location: @user }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @user.errors, status: :unprocessable_entity }
      end
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_user
      requested_id = params.expect(:id).to_s
      raise ActiveRecord::RecordNotFound unless requested_id == current_user.id.to_s

      @user = current_user
    end

    # Only allow a list of trusted parameters through.
    def user_params
      params.expect(user: [ :name, :username, :email_address, :bio, :password, :password_confirmation ])
    end
end
