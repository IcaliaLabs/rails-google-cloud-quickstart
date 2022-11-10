# frozen_string_literal: true

require 'net/http'

module IdentityPlatform
  # Retrieves and stores the certificates used to properly decode tokens issued
  # by Google Cloud Identity Platform
  class CertStore
    extend MonitorMixin

    CERTS_URI = 'https://www.googleapis.com/robot/v1/metadata/x509/securetoken@system.gserviceaccount.com'
    CERTS_EXPIRY = 3600

    mattr_reader :certs_last_refresh

    def self.certs_cache_expired?
      return true unless certs_last_refresh

      Time.current > certs_last_refresh + CERTS_EXPIRY
    end

    def self.certs
      refresh_certs if certs_cache_expired?
      @@certs
    end

    def self.fetch_certs
      certs_uri = URI(CERTS_URI)
      get = Net::HTTP::Get.new certs_uri.request_uri
      http = Net::HTTP.new(certs_uri.host, certs_uri.port)
      http.use_ssl = true
      res = http.request(get)
      return res if res.is_a?(Net::HTTPSuccess)
    end

    def self.refresh_certs
      synchronize do
        return unless (res = fetch_certs)

        new_certs = JSON.parse(res.body).transform_values do |cert|
          OpenSSL::X509::Certificate.new(cert)
        end

        (@@certs ||= {}).merge! new_certs
        @@certs_last_refresh = Time.current
      end
    end
  end
end
