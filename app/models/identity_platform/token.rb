# frozen_string_literal: true

module IdentityPlatform
  # The token we obtain when authenticating users through Google Cloud Identity
  # Platform
  class Token
    include ActiveModel::Model
    include ActiveModel::Attributes
    include ActiveModel::Validations::Callbacks

    ISSUER_PREFIX = 'https://securetoken.google.com/'

    PAYLOAD_KEY_MAP = {
      'iss' => 'issuer',
      'sub' => 'subject',
      'aud' => 'audience',
      'iat' => 'issued_at',
      'exp' => 'expires_at',
      'auth_time' => 'authenticated_at'
    }.freeze

    PAYLOAD_MAPPER = proc { |key| PAYLOAD_KEY_MAP.fetch key, key }

    # Transient attributes:
    attr_accessor :token, :payload, :header

    attribute :issuer,           type: :string
    attribute :subject,          type: :string
    attribute :audience,         type: :string
    attribute :issued_at,        type: :datetime
    attribute :expires_at,       type: :datetime
    attribute :authenticated_at, type: :datetime
    attribute :created_at,       type: :datetime

    before_validation :extract_token_payload

    def self.load(given_token)
      new(token: given_token)
    end

    def self.decode_token_with_cert(token, key, cert)
      public_key = cert.public_key

      JWT.decode(
        token,
        public_key,
        !public_key.nil?,
        decoding_options.merge(kid: key)
      )
    end

    def self.expected_audience
      ENV.fetch 'GOOGLE_CLOUD_PROJECT', 'rails-google-cloud-quickstart'
    end

    def self.expected_issuer
      "#{ISSUER_PREFIX}#{expected_audience}"
    end

    def self.decoding_options
      {
        algorithm: 'RS256',
        iss: expected_issuer,
        aud: expected_audience,
        verify_aud: true,
        verify_iss: true
      }
    end

    delegate :certs, to: CertStore
    delegate :decode_token_with_cert, to: :class

    private

    def extract_token_payload
      decode_token_with_certs
      return errors.add(:token, 'invalid token') if payload.blank?

      assign_attributes string_attributes_from_payload
      assign_attributes timestamp_attributes_from_payload
    end

    def string_attributes_from_payload
      payload.slice(*%w[iss sub aud]).transform_keys(&PAYLOAD_MAPPER)
    end

    def timestamp_attributes_from_payload
      payload
        .slice(*%w[iat exp auth_time])
        .transform_keys(&PAYLOAD_MAPPER)
        .transform_values { |value| Time.at(value) }
    end

    def decode_token_with_certs
      certs.detect do |key, cert|
        assign_payload_and_header_with_key_and_cert(key, cert)
        break if payload.present? || errors.any?
      end
    end

    def assign_payload_and_header_with_key_and_cert(key, cert)
      return if payload.present?

      @payload, @header = decode_token_with_cert(token, key, cert)
      @payload = @payload&.with_indifferent_access
    rescue JWT::ExpiredSignature
      errors.add :token, 'signature expired'
    rescue JWT::InvalidIssuerError
      errors.add :token, 'invalid issuer'
    rescue JWT::DecodeError
      nil
    end
  end
end
