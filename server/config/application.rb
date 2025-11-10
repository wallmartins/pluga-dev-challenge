# frozen_string_literal: true
require_relative "boot"
require "rails/all"

Bundler.require(*Rails.groups)

module Backend
  class Application < Rails::Application
    config.load_defaults 8.1
    config.api_only = true
    
    config.autoloader = :zeitwerk
    
    config.eager_load = false if Rails.env.development? || Rails.env.test?
  end
end