class PasswordResetMailer < ApplicationMailer
  def reset
    @user = params[:user]
    @token = @user.generate_token_for(:password_reset)
    @reset_url = edit_password_reset_url(@token)

    mail to: @user.email_address, subject: "Reset your Board Base password"
  end
end
