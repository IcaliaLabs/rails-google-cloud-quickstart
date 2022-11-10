# frozen_string_literal: true

# A person who has an account on the site (via Google Cloud Identity Platform).
class User < ApplicationRecord
  validates :identity_platform_id, presence: true, uniqueness: true

  def self.from_identity_token(token)
    return unless token.valid?

    find_or_initialize_by(identity_platform_id: token.subject).tap do |user|
      user.update! token.payload.slice(:name, :email)
    end
  end
end
