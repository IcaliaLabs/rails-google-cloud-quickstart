# frozen_string_literal: true

# See https://evilmartians.com/chronicles/system-of-a-test-setting-up-end-to-end-rails-testing

# BetterRailsSystemTests
#
# A list of methods to be added to system tests to enhance the development
# experience
module BetterRailsSystemTests
  # Use our `Capybara.save_path` to store screenshots with other capybara
  # artifacts (Rails screenshots path is not configurable
  # https://github.com/rails/rails/blob/49baf092439fc74fc3377b12e3334c3dd9d0752f/actionpack/lib/action_dispatch/system_testing/test_helpers/screenshot_helper.rb#L79)
  def absolute_image_path
    Rails.root.join("#{Capybara.save_path}/screenshots/#{image_name}.png")
  end

  # Use relative path in screenshot message to make it clickable in VS Code when
  # running in Docker
  def image_path
    absolute_image_path.relative_path_from(Rails.root).to_s
  end

  # Make failure screenshots compatible with multi-session setup
  def take_screenshot
    return super unless (last_session = Capybara.last_used_session)

    Capybara.using_session(last_session) { super }
  end

  # Convert dom_id to selector
  def dom_id(*args)
    "##{super}"
  end
end

RSpec.configure do |config|
  # Add #dom_id support
  config.include ActionView::RecordIdentifier, type: :system
  config.include BetterRailsSystemTests, type: :system

  # Make urls in mailers contain the correct server host.
  # It's required for testing links in emails (e.g., via capybara-email).
  config.around(:each, type: :system) do |ex|
    was_host = (rails_app = Rails.application).default_url_options[:host]
    rails_app.default_url_options[:host] = Capybara.server_host
    ex.run
    rails_app.default_url_options[:host] = was_host
  end

  # Make sure this hook runs before others
  config.prepend_before(:each, type: :system) do
    # Use JS driver always
    driven_by Capybara.javascript_driver
  end
end
