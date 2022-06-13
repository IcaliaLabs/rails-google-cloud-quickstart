ENV['BUNDLE_GEMFILE'] ||= File.expand_path('../Gemfile', __dir__)

require 'bundler/setup' # Set up gems listed in the Gemfile.
require 'bootsnap/setup' # Speed up boot time by caching expensive operations.

# Uncomment the lines that you want to use:

# Allow 'on_container/load_env_secrets' to load secrets from Google Cloud Secret
# Manager service by requiring 'google/cloud/secret_manager' first:
# require 'google/cloud/secret_manager'

# Load mounted secrets to ENV:
require 'on_container/load_env_secrets'
