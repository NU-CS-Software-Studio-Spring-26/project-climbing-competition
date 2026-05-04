class SessionsController < ApplicationController
  def new
  end

  def create
    session_params = params.expect(session: [ :email_address, :password ])
    user = User.find_by(email_address: session_params[:email_address].to_s.downcase)

    if user&.authenticate(session_params[:password])
      terminate_session
      start_new_session_for(user)
      redirect_to(session.delete(:return_to) || competitions_path, notice: "Signed in successfully.", status: :see_other)
    else
      flash.now[:alert] = "The email address or password is incorrect."
      render :new, status: :unprocessable_entity
    end
  end

  def destroy
    terminate_session
    redirect_to root_path, notice: "Signed out successfully.", status: :see_other
  end
end
