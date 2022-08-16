# frozen_string_literal: true

require 'system_helper'

RSpec.describe 'Home page', type: :system do
  let(:example_user) { create :user }

  scenario 'visit the home page without signin in' do
    visit root_path

    expect(page).to have_content 'Hello!'
    expect(page).to have_content 'Sign in?'
  end

  scenario 'visit the home page as a signed-in user' do
    sign_in_as example_user
    visit root_path

    expect(page).to have_content "Hello #{example_user.email}!"
    expect(page).to have_content 'Sign out?'
  end
end
