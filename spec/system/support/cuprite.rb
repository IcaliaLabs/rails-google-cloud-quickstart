# frozen_string_literal: true

# See https://evilmartians.com/chronicles/system-of-a-test-setting-up-end-to-end-rails-testing

require 'capybara/cuprite'

# Parse URL
# NOTE: REMOTE_CHROME_HOST should be added to Webmock/VCR allowlist if you use
# any of those.
REMOTE_CHROME_URL, REMOTE_CHROME_HOST, REMOTE_CHROME_PORT =
  if (chrome_url = ENV['CHROME_URL'])
    URI.parse(chrome_url).yield_self do |uri|
      uri.host = IPSocket.getaddress(uri.host)
      [uri.to_s, uri.host, uri.port]
    end
  end

# Check whether the remote chrome is running.
remote_chrome =
  begin
    if REMOTE_CHROME_URL.nil?
      false
    else
      Socket
        .tcp(REMOTE_CHROME_HOST, REMOTE_CHROME_PORT, connect_timeout: 1)
        .close
      true
    end
  rescue Errno::ECONNREFUSED, Errno::EHOSTUNREACH, SocketError
    false
  end

remote_options = remote_chrome ? { url: REMOTE_CHROME_URL } : {}

# Allow requests to the remote google chrome service, if configured
if remote_chrome
  WebMock::Config.instance.allow ||= []
  WebMock::Config.instance.allow << REMOTE_CHROME_URL
end

Capybara.register_driver(:cuprite_remote) do |app|
  Capybara::Cuprite::Driver.new(
    app,
    **{
      window_size: [1200, 800],
      # See additional options for Dockerized environment in the respective
      # section of this article
      browser_options: remote_chrome ? { 'no-sandbox' => nil } : {},
      # Increase Chrome startup wait time (required for stable CI builds)
      process_timeout: 10,
      # Enable debugging capabilities
      inspector: true,
      # Allow running Chrome in a headful mode by setting HEADLESS env
      # var to a falsey value
      headless: !ENV['HEADLESS'].in?(%w[n 0 no false])
    }.merge(remote_options)
  )
end

# Configure Capybara to use :cuprite driver by default
Capybara.default_driver = Capybara.javascript_driver = :cuprite_remote

# A couple of methods used to help the development of system tests
module CupriteHelpers
  # Drop #pause anywhere in a test to stop the execution.
  # Useful when you want to checkout the contents of a web page in the middle of
  # a test running in a headful mode.
  def pause
    page.driver.pause
  end

  # Drop #debug anywhere in a test to open a Chrome inspector and pause the
  # execution
  def debug(binding = nil)
    chrome_public_url = ENV.fetch 'CHROME_PUBLIC_URL', 'http://localhost:9222'
    $stdout.puts "🔎 Open Chrome inspector at #{chrome_public_url}"
    return binding.respond_to?(:pry) ? binding.pry : binding.irb if binding

    page.driver.pause
  end
end

RSpec.configure do |config|
  config.include CupriteHelpers, type: :system
end
