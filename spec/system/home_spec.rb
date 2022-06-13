
require 'system_helper'

RSpec.describe 'Home page', type: :system do
  scenario 'visit the home page' do
    visit root_url
    expect(page).to have_content 'Find me in app/views/home/show.html.erb'
  end
end