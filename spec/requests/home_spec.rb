# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Homes', type: :request do
  describe 'GET /show' do
    it 'returns http success' do
      get '/'
      expect(response).to have_http_status(:success)
    end
  end
end
