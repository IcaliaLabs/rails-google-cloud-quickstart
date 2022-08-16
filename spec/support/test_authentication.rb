# frozen_string_literal: true

module RequestSpecAuthHelper
  include Warden::Test::Helpers

  def self.included(base)
    base.before { Warden.test_mode! }
    base.after { Warden.test_reset! }
  end

  def sign_in_as(...)
    login_as(...)
  end

  def sign_out(...)
    logout(...)
  end
end

module RequestSpecAuthMacros
  def signed_in_as(given_variable_or_factory_name)
    before :example do
      user_to_sign_in = if respond_to? given_variable_or_factory_name
                          send given_variable_or_factory_name
                        else
                          create given_variable_or_factory_name
                        end

      sign_in_as user_to_sign_in
    end
  end
end

RSpec.configure do |config|
  %i[request feature system].each do |spec_type|
    config.include RequestSpecAuthHelper, type: spec_type
    config.extend  RequestSpecAuthMacros, type: spec_type
  end
end
