# frozen_string_literal: true

# Handles the user session web requests
class SessionController < ApplicationController
  def new; end

  def create
    token = IdentityPlatform::Token.load session_params[:token]

    if token.valid? && sign_in_token_user(token)
      redirect_to session.fetch :after_sign_in_path, root_path
    else
      render :new, status: :unprocessable_entity
    end
  end

  def destroy
    sign_out_user
    redirect_to new_session_path
  end

  private

  def session_params
    params.require(:session).permit :token
  end

  def sign_in_token_user(token, scope: :default)
    user = User.from_identity_token token
    warden.set_user(user, scope:)
  end

  def sign_out_user(scope: nil)
    if scope
      warden.logout(scope)
      warden.clear_strategies_cache!(scope:)
    else
      warden.logout
      warden.clear_strategies_cache!
    end
  end
end
