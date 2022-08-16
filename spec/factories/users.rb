# frozen_string_literal: true

FactoryBot.define do
  factory :user do
    sequence(:email) { |n| "user-#{n}@example.com" }
    sequence(:identity_platform_id) { |n| "example-user-#{n}" }

    trait :with_name do
      sequence(:name) { |n| "Example User #{n}" }
    end
  end
end
