# frozen_string_literal: true

require 'rails_helper'
require_relative '../../shared/context/example_identity_token'

RSpec.describe IdentityPlatform::Token, type: :model do
  include_context 'example identity token'

  subject { described_class.load example_token }

  before do
    allow(described_class).to receive(:expected_audience).and_return example_token_audience

    allow(IdentityPlatform::CertStore).to receive(:certs).and_return(
      { example_token_signature_cert_id => example_token_signature_cert }
    )
  end

  describe '.load' do
    subject(:loaded_token) { described_class.load example_token }

    it 'initializes an instance with the given token' do
      expect(loaded_token).to have_attributes token: example_token
    end
  end

  describe 'validations (JWT decoding)' do
    context 'from an unexpected issuer' do
      before do
        allow(described_class).to receive(:expected_audience).and_return 'other-audience'
      end

      it 'is invalid' do
        expect(subject).not_to be_valid
      end

      it 'adds the "invalid issuer" error to the validation error list' do
        expect(subject).not_to be_valid
        expect(subject.errors.where(:token, 'invalid issuer')).to be_any
      end
    end
  end

  describe 'attributes' do
    context 'when valid' do
      before { expect(subject).to be_valid }

      it "extracts attributes from the given token's payload" do
        expect(subject).to have_attributes(
          issuer: example_token_issuer,
          subject: example_user_identity_platform_id,
          audience: example_token_audience,
          issued_at: example_token_issue_time,
          expires_at: example_token_expiration_time,
          authenticated_at: example_authentication_time
        )
      end
    end
  end
end
