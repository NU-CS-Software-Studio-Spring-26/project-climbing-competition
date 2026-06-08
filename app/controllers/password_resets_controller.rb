class PasswordResetsController < ApplicationController
  before_action :set_user_by_token, only: %i[ edit update ]

  def new
  end

  def create
    email = params.dig(:password_reset, :email_address).to_s.strip.downcase
    user = User.find_by(email_address: email)

    PasswordResetMailer.with(user: user).reset.deliver_later if user&.password_resettable?

    redirect_to new_session_path,
      notice: "If that email is registered with a password account, you will receive reset instructions shortly."
  end

  def edit
  end

  def update
    if @user.update(password_reset_params)
      @user.sessions.destroy_all
      redirect_to new_session_path, notice: "Your password has been reset. Sign in with your new password."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  private
    def set_user_by_token
      @user = User.find_by_token_for(:password_reset, params[:token])

      return if @user&.password_resettable?

      redirect_to new_password_reset_path, alert: "Password reset link is invalid or has expired."
    end

    def password_reset_params
      params.expect(password_reset: [ :password, :password_confirmation ])
    end
end
