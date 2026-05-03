module Authentication
  extend ActiveSupport::Concern

  included do
    before_action :resume_session
    helper_method :authenticated?, :current_user
  end

  private
    def authenticated?
      current_user.present?
    end

    def current_user
      Current.user
    end

    def resume_session
      Current.session ||= find_session
    end

    def find_session
      return unless cookies.signed[:session_id] && cookies.signed[:session_token]

      Session.find_by(id: cookies.signed[:session_id], token: cookies.signed[:session_token])
    end

    def require_authentication
      return if authenticated?

      session[:return_to] = request.fullpath
      redirect_to new_session_path, alert: "Please sign in to continue."
    end

    def start_new_session_for(user)
      session_record = user.sessions.create!(user_agent: request.user_agent, ip_address: request.remote_ip)
      Current.session = session_record
      cookies.signed.permanent[:session_id] = { value: session_record.id, httponly: true, same_site: :lax }
      cookies.signed.permanent[:session_token] = { value: session_record.token, httponly: true, same_site: :lax }
    end

    def terminate_session
      Current.session&.destroy
      cookies.delete(:session_id)
      cookies.delete(:session_token)
      Current.session = nil
    end
end