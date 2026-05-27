google_client_id = ENV["GOOGLE_CLIENT_ID"] || Rails.application.credentials.dig(:google_oauth, :client_id)
google_client_secret = ENV["GOOGLE_CLIENT_SECRET"] || Rails.application.credentials.dig(:google_oauth, :client_secret)

Rails.application.config.middleware.use OmniAuth::Builder do
  provider :google_oauth2,
           google_client_id,
           google_client_secret,
           {
             scope: "email,profile",
             prompt: "select_account"
           }
end

OmniAuth.config.allowed_request_methods = [ :post ]