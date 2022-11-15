# frozen_string_literal: true

# Base controller used to handle web requests
class ApplicationController < ActionController::Base
  helper_method :current_user, :user_signed_in?

  def warden
    request.env['warden']
  end

  def user_signed_in?(...)
    warden.authenticated?(...)
  end

  def authenticate_user!(...)
    session[:after_sign_in_path] = request.path unless user_signed_in?(...)
    warden.authenticate!(...)
  end

  def after_sign_in_path
    session.delete(:after_sign_in_path) || root_path
  end

  def current_user(...)
    warden.user(...)
  end
end
