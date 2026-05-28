class OmniauthCallbacksController < ApplicationController
  def create
    auth = request.env["omniauth.auth"]
    result = Omniauth::Authenticator.call(auth)

    if result.user
      terminate_session
      start_new_session_for(result.user)
      redirect_to session.delete(:return_to) || competitions_path, notice: "Signed in successfully.", status: :see_other
    else
      redirect_to new_session_path, alert: result.error || "Sign in failed. Please try again.", status: :see_other
    end
  end

  def failure
    message = params[:message].presence || "Sign in was cancelled or failed."
    redirect_to new_session_path, alert: message, status: :see_other
  end
end
