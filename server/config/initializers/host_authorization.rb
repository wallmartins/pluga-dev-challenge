# frozen_string_literal: true

# Configure host authorization for testing
# This allows requests from localhost and 127.0.0.1 in test environment
if Rails.env.test?
  Rails.application.config.hosts << "localhost"
  Rails.application.config.hosts << "127.0.0.1"
  Rails.application.config.hosts << "::1" # IPv6 localhost
end
