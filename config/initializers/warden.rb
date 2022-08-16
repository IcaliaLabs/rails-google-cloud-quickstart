# frozen_string_literal: true

Rails.application.reloader.to_prepare do
  Warden::Strategies.add :identity_token, IdentityPlatform::WardenStrategy
end

Rails.application.config.middleware.use Warden::Manager do |manager|
  manager.default_strategies :identity_token
  manager.failure_app = UnauthorizedController

  manager.serialize_into_session(&:id)
  manager.serialize_from_session { |id| User.find_by id: }
end
