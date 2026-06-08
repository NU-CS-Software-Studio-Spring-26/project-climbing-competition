class SessionsController < ApplicationController
  skip_before_action :verify_authenticity_token, only: :google_callback

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

  def google_callback
    auth = request.env["omniauth.auth"]
    raise ArgumentError, "Missing Google auth payload" if auth.blank?

    user = find_or_create_user_from_google(auth)

    terminate_session
    start_new_session_for(user)
    redirect_to(session.delete(:return_to) || competitions_path, notice: "Signed in with Google.", status: :see_other)
  rescue StandardError
    redirect_to new_session_path, alert: "Google sign-in failed. Please try again.", status: :see_other
  end

  def omniauth_failure
    redirect_to new_session_path, alert: "Google sign-in failed. Please try again.", status: :see_other
  end

  private

  def find_or_create_user_from_google(auth)
    google_uid = auth["uid"].to_s
    email = auth.dig("info", "email").to_s.downcase
    name = auth.dig("info", "name").to_s

    raise ArgumentError, "Google account must include an email" if email.blank?

    user = User.find_by(google_uid: google_uid) || User.find_by(email_address: email)
    return link_google_account(user, google_uid) if user.present?

    create_google_user(email:, name:, google_uid:)
  end

  def link_google_account(user, google_uid)
    return user if user.google_uid == google_uid

    user.update!(google_uid: google_uid)
    user
  end

  def create_google_user(email:, name:, google_uid:)
    password = SecureRandom.base58(24)

    user = User.new(
      name: name.presence || email.split("@").first.to_s.titleize,
      email_address: email,
      username: build_unique_username(email),
      google_uid: google_uid,
      password: password,
      password_confirmation: password
    )

    user.save!
    user
  end

  def build_unique_username(email)
    local_part = email.split("@").first.to_s
    base = local_part.downcase.gsub(/[^a-z0-9_.-]/, "").slice(0, User::USERNAME_MAX_LENGTH)
    base = "climber" if base.blank?

    candidate = base
    suffix = 1

    while User.username_taken?(candidate)
      suffix_text = suffix.to_s
      candidate = "#{base.slice(0, User::USERNAME_MAX_LENGTH - suffix_text.length)}#{suffix_text}"
      suffix += 1
    end

    candidate
  end
end
