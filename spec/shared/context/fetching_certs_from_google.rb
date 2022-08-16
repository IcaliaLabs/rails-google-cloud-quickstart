# frozen_string_literal: true

RSpec.shared_context 'fetching certs from google' do
  let(:example_cert_service_response_data) do
    JSON.parse file_fixture('google-cert-server-response.json').read
  end

  let :example_cert_service_response do
    instance_double 'Net::HTTPOK',
                    body: example_cert_service_response_data.to_json
  end

  before do
    allow(IdentityPlatform::CertStore)
      .to receive(:fetch_certs)
      .and_return example_cert_service_response
  end
end
