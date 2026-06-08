class ApplicationController < ActionController::Base
  include Authentication

  rescue_from ActionController::ParameterMissing, with: :handle_missing_parameters

  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  # Changes to the importmap will invalidate the etag for HTML responses
  stale_when_importmap_changes

  private

  def handle_missing_parameters
    respond_to do |format|
      format.html do
        redirect_back fallback_location: root_path,
                      alert: "Something was missing from your request. Please try again.",
                      status: :see_other
      end
      format.json { render json: { error: "Missing required parameter" }, status: :bad_request }
    end
  end
end
