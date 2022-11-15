# frozen_string_literal: true

source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby '3.1.2'

# Bundle edge Rails instead: gem "rails", github: "rails/rails", branch: "main"
gem 'rails', '~> 7.0.4'

# The original asset pipeline for Rails [https://github.com/rails/sprockets-rails]
gem 'sprockets-rails'

# Use postgresql as the database for Active Record
gem 'pg', '~> 1.1'

# Use the Puma web server [https://github.com/puma/puma]
gem 'puma', '~> 5.0'

# Use JavaScript with ESM import maps [https://github.com/rails/importmap-rails]
gem 'importmap-rails'

# Hotwire's SPA-like page accelerator [https://turbo.hotwired.dev]
gem 'turbo-rails'

# Hotwire's modest JavaScript framework [https://stimulus.hotwired.dev]
gem 'stimulus-rails'

# Use Tailwind CSS [https://github.com/rails/tailwindcss-rails]
gem 'tailwindcss-rails'

# Build JSON APIs with ease [https://github.com/rails/jbuilder]
gem 'jbuilder'

# Use Redis adapter to run Action Cable in production
# gem "redis", "~> 4.0"

# Use Kredis to get higher-level data types in Redis [https://github.com/rails/kredis]
# gem "kredis"

# Use Active Model has_secure_password [https://guides.rubyonrails.org/active_model_basics.html#securepassword]
# gem "bcrypt", "~> 3.1.7"

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem 'tzinfo-data', platforms: %i[mingw mswin x64_mingw jruby]

# Reduces boot times through caching; required in config/boot.rb
gem 'bootsnap', require: false

# Routines we use in containerized apps
gem 'on_container', '~> 0.0.17'

# Use Sass to process CSS
# gem "sassc-rails"

# Use Active Storage variants [https://guides.rubyonrails.org/active_storage_overview.html#transforming-images]
# gem "image_processing", "~> 1.2"

# To decode the tokens
gem 'jwt', '~> 2.5'

# An authentication library compatible with all Rack-based frameworks
gem 'warden', '~> 1.2', '>= 1.2.9'

group :development, :test do
  # See https://guides.rubyonrails.org/debugging_rails_applications.html#debugging-with-the-debug-gem
  gem 'debug', platforms: %i[mri mingw x64_mingw]

  # We'll use RSpec as the testing framework for Rails
  gem 'rspec-rails', '~> 6.0', '>= 6.0.1'

  # A framework and DSL for defining and using test factories - more explicit,
  # and all-around easier to work with than fixtures.
  gem 'factory_bot_rails', '~> 6.2'
end

group :development do
  # Use console on exceptions pages [https://github.com/rails/web-console]
  gem 'web-console'

  # Add speed badges [https://github.com/MiniProfiler/rack-mini-profiler]
  # gem "rack-mini-profiler"

  # Speed up commands on slow machines / big apps [https://github.com/rails/spring]
  # gem "spring"

  # Linters, etc:
  gem 'htmlbeautifier', '~> 1.4', '>= 1.4.2', require: false

  # Ruby code style checking and code formatting tool. It aims to enforce the
  # community-driven Ruby Style Guide.
  gem 'rubocop', '~> 1.38', require: false

  # IDE tools for code completion, inline documentation, and static analysis
  gem 'solargraph', '~> 0.47.2', require: false

  # Process manager for applications with multiple components - we'll use it to
  # launch both Rails and TailwindCSS processes in one go.
  gem 'foreman', '~> 0.87.2', require: false
end

group :test do
  # Use system testing [https://guides.rubyonrails.org/testing.html#system-testing]
  gem 'capybara'

  # Provides RSpec- and Minitest-compatible one-liners to test common Rails
  # functionality that, if written by hand, would be much longer, more complex,
  # and error-prone.
  gem 'shoulda-matchers', '~> 5.2'

  # A driver for Capybara that allows you to run your tests on a headless Chrome
  # browser
  gem 'cuprite', '~> 0.14.3'

  # Ruby applications tests profiling tools. Contains tools to analyze factories
  # usage, integrate with Ruby profilers, profile your examples using
  # ActiveSupport notifications (if any) and statically analyze your code with
  # custom RuboCop cops:
  gem 'test-prof', '~> 1.0', '>= 1.0.11'

  # Allows stubbing HTTP requests and setting expectations on HTTP requests.
  gem 'webmock', '~> 3.18', '>= 3.18.1'

  # Generates test vs. code coverage reports
  gem 'simplecov', '~> 0.21.2', require: false

  # We'll use sinatra to implement our mock servers for testing:
  gem 'sinatra', '~> 3.0', '>= 3.0.2', require: false
end
