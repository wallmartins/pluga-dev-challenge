# frozen_string_literal: true

require_relative "boot"
require "rails/all"

Bundler.require(*Rails.groups)

module Backend
  class Application < Rails::Application
    config.load_defaults 8.1

    config.autoload_lib(ignore: %w[assets tasks])

    config.autoload_paths += %W[
      #{config.root}/app/exceptions
      #{config.root}/app/lib
    ]

    config.eager_load_paths += %W[
      #{config.root}/app/exceptions
      #{config.root}/app/lib
    ]

    config.api_only = true
  end
end
