# frozen_string_literal: true

require 'rails_helper'
require_relative '../../shared/context/fetching_certs_from_google'

RSpec.describe IdentityPlatform::CertStore do
  include_context 'fetching certs from google'

  describe '.certs' do
    subject { described_class }

    it 'returns a hash of certs' do
      expect(subject.certs.keys).to include(*example_cert_service_response_data.keys)
    end

    context 'when the cache expires' do
      before { allow(described_class).to receive(:certs_cache_expired?).and_return true }

      it 'fetches the certs from the server' do
        expect(described_class).to receive(:fetch_certs)
        subject.certs
      end

      it 'changes the value of .certs_last_refresh' do
        expect { subject.certs }.to change(described_class, :certs_last_refresh)
      end
    end

    context 'when the cache has not expired' do
      before { allow(described_class).to receive(:certs_cache_expired?).and_return false }

      it 'fetches the certs from the server' do
        expect(described_class).not_to receive(:fetch_certs)
        subject.certs
      end
    end
  end
end
