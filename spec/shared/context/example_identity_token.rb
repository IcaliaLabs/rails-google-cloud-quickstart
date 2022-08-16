# frozen_string_literal: true

RSpec.shared_context 'example identity token' do
  let(:example_authentication_time) { Time.current.round(0) }
  let(:example_token_issue_time) { Time.current.round(0) }
  let(:example_token_audience) { 'example-project' }
  let(:example_token_issuer) { "https://securetoken.google.com/#{example_token_audience}" }

  let(:example_user) { create :user, :with_name }
  let(:example_user_name) { example_user.name }
  let(:example_user_email) { example_user.email }
  let(:example_user_identity_platform_id) { example_user.identity_platform_id }

  let :example_token_expiration_time do
    Time.at(example_token_issue_time.to_i + 100_000)
  end

  let :example_token_root_ca_pkey do
    OpenSSL::PKey::RSA.generate 2048 # the CA's public/private key
  end

  let :example_token_root_ca_cert do
    OpenSSL::X509::Certificate.new.tap do |cert|
      cert.version = 2 # cf. RFC 5280 - to make it a "v3" certificate
      cert.serial = 1
      cert.subject = OpenSSL::X509::Name.parse '/DC=org/DC=ruby-lang/CN=Ruby CA'
      cert.issuer = cert.subject # root CA's are "self-signed"
      cert.public_key = example_token_root_ca_pkey.public_key
      cert.not_before = Time.now
      cert.not_after = cert.not_before + 2 * 365 * 24 * 60 * 60 # 2 years validity

      ef = OpenSSL::X509::ExtensionFactory.new
      ef.subject_certificate = cert
      ef.issuer_certificate = cert
      cert.add_extension ef.create_extension('basicConstraints', 'CA:TRUE', true)
      cert.add_extension ef.create_extension('keyUsage', 'keyCertSign, cRLSign', true)
      cert.add_extension ef.create_extension('subjectKeyIdentifier', 'hash', false)
      cert.add_extension ef.create_extension('authorityKeyIdentifier', 'keyid:always', false)
      cert.sign example_token_root_ca_pkey, OpenSSL::Digest.new('SHA256')
    end
  end

  let :example_token_signature_pkey do
    OpenSSL::PKey::RSA.generate 2048
  end

  let :example_token_signature_cert do
    OpenSSL::X509::Certificate.new.tap do |cert|
      cert.version = 2
      cert.serial = 2
      cert.subject = OpenSSL::X509::Name.parse '/DC=org/DC=ruby-lang/CN=Ruby certificate'
      cert.issuer = example_token_root_ca_cert.subject # root CA is the issuer
      cert.public_key = example_token_signature_pkey.public_key
      cert.not_before = Time.now
      cert.not_after = cert.not_before + 1 * 60 * 60 # 1 hour validity
      ef = OpenSSL::X509::ExtensionFactory.new
      ef.subject_certificate = cert
      ef.issuer_certificate = example_token_root_ca_cert
      cert.add_extension ef.create_extension('keyUsage', 'digitalSignature', true)
      cert.add_extension ef.create_extension('subjectKeyIdentifier', 'hash', false)
      cert.sign example_token_root_ca_pkey, OpenSSL::Digest.new('SHA256')
    end
  end

  let :example_token_signature_cert_id do
    '0000000000000000000000000000000000000001'
  end

  let :example_token_payload do
    {
      'aud' => example_token_audience,
      'name' => example_user_name,
      'iss' => example_token_issuer,
      'email' => example_user_email,
      'iat' => example_token_issue_time.to_i,
      'sub' => example_user_identity_platform_id,
      'exp' => example_token_expiration_time.to_i,
      'user_id' => example_user_identity_platform_id,
      'auth_time' => example_authentication_time.to_i
    }
  end

  let :example_token do
    JWT.encode example_token_payload, example_token_signature_pkey, 'RS256'
  end
end
