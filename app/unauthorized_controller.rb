# frozen_string_literal: true

# UnauthorizedController
#
# The controller configured to be used by Warden to deal whenever the
# authentication fails - either by harshly stopping with an HTTP 401 Unauthorized
# status, or redirecting to the sign-in page.
class UnauthorizedController < ActionController::Metal
  include ActionController::Head
  include ActionController::Redirecting
  include Rails.application.routes.url_helpers

  cattr_accessor :navigational_formats, default: ['*/*', :html]

  def self.call(env)
    @respond ||= action(:respond)
    @respond.call(env)
  end

  def respond
    return head :unauthorized unless navigational_format?

    redirect_to sign_in_path, alert: 'You need to sign in before continuing.'
  end

  private

  def navigational_format?
    request.format.try(:ref).in? navigational_formats
  end
end
