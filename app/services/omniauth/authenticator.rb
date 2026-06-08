# frozen_string_literal: true

module Omniauth
  class Authenticator
    Result = Data.define(:user, :error)

    def self.call(auth)
      new(auth).call
    end

    def initialize(auth)
      @auth = auth
    end

    def call
      identity = Identity.find_by(provider: @auth.provider, uid: @auth.uid.to_s)
      return Result.new(user: identity.user, error: nil) if identity

      email = resolve_email
      return Result.new(user: nil, error: "We could not get an email address from your account. Try another sign-in method or use email sign-up.") if email.blank?

      user = User.find_by(email_address: email)
      if user
        user.identities.create!(provider: @auth.provider, uid: @auth.uid.to_s)
        return Result.new(user: user, error: nil)
      end

      user = build_user(email)
      ActiveRecord::Base.transaction do
        user.save!
        user.identities.create!(provider: @auth.provider, uid: @auth.uid.to_s)
      end
      Result.new(user: user, error: nil)
    rescue ActiveRecord::RecordInvalid => e
      Result.new(user: nil, error: e.record.errors.full_messages.to_sentence)
    end

    private
      def resolve_email
        email = @auth.info.email&.strip&.downcase
        return email if email.present?

        fetch_github_primary_email if @auth.provider == "github"
      end

      def fetch_github_primary_email
        access_token = @auth.credentials&.token
        return if access_token.blank?

        response = Faraday.get(
          "https://api.github.com/user/emails",
          nil,
          {
            "Authorization" => "Bearer #{access_token}",
            "Accept" => "application/vnd.github+json",
            "User-Agent" => "climbing-competition"
          }
        )
        return unless response.success?

        emails = JSON.parse(response.body)
        primary = emails.find { |entry| entry["primary"] && entry["verified"] }
        primary ||= emails.find { |entry| entry["verified"] }
        primary&.dig("email")&.strip&.downcase
      rescue JSON::ParserError, Faraday::Error
        nil
      end

      def build_user(email)
        User.new(
          email_address: email,
          name: resolve_name,
          username: unique_username(base_username(email))
        )
      end

      def resolve_name
        name = @auth.info.name&.strip&.squish
        return name if name.present? && name.match?(User::UNICODE_LETTER_PATTERN)

        "Climber"
      end

      def base_username(email)
        candidate = if @auth.provider == "github" && @auth.info.nickname.present?
          @auth.info.nickname
        else
          email.split("@", 2).first
        end

        sanitize_username(candidate)
      end

      def sanitize_username(value)
        sanitized = value.to_s.downcase.gsub(/[^a-z0-9_.-]/, "_").gsub(/_{2,}/, "_")
        sanitized = sanitized.gsub(/\A[^a-z0-9]+|[^a-z0-9_.-]+\z/, "")
        sanitized = "climber" if sanitized.blank? || sanitized.length < 1
        sanitized[0, User::USERNAME_MAX_LENGTH]
      end

      def unique_username(base)
        candidate = base
        suffix = 2
        while User.where("LOWER(username) = ?", candidate.downcase).exists?
          suffix_part = suffix.to_s
          max_base_length = User::USERNAME_MAX_LENGTH - suffix_part.length
          candidate = "#{base[0, max_base_length]}#{suffix_part}"
          suffix += 1
        end
        candidate
      end
  end
end
