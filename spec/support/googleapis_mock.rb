# frozen_string_literal: true

require 'sinatra/base'

class GoogleapisMock < Sinatra::Base
  def self.routes_as_stub_params
    @routes_as_stub_params ||= routes.each_with_object([]) do |(method, routes), stub_params|
      method_param = method.downcase.to_sym
      routes.each do |route|
        stub_params << [method_param, Regexp.new(
          "www.googleapis.com#{route.first.regexp.source[2..-3]}",
          Regexp::IGNORECASE
        )]
      end
    end
  end

  get '/robot/v1/metadata/x509/securetoken@system.gserviceaccount.com' do
    content_type :json
    status 200
    Rails.root.join(
      'spec/fixtures/files/google-cert-server-response.json'
    ).read
  end
end

RSpec.configure do |config|
  config.before(:each) do
    GoogleapisMock.routes_as_stub_params.each do |stub_params|
      stub_request(*stub_params).to_rack GoogleapisMock
    end
  end
end
