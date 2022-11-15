# frozen_string_literal: true

module IdentityPlatform
  # A warden strategy to authenticate users with a token from Google Cloud
  # Identity Platform
  class WardenStrategy < Warden::Strategies::Base
    def valid?
      !token_string.nil?
    end

    def authenticate!
      fail! 'invalid_token' and return unless token&.valid?

      success! User.from_identity_token(token)
    end

    def store?
      false
    end

    private

    def token
      @token ||= IdentityPlatform::Token.load(token_string) if valid?
    end

    def token_string
      token_string_from_header || token_string_from_request_params
    end

    def token_string_from_header
      Rack::Auth::AbstractRequest::AUTHORIZATION_KEYS.each do |key|
        if env.key?(key) && (token_string = env[key][/^Bearer (.*)/, 1])
          return token_string
        end
      end
      nil
    end

    def token_string_from_request_params
      params['access_token']
    end
  end
end
