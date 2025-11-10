# frozen_string_literal: true

Dir[Rails.root.join("app/exceptions/*.rb")].each { |f| require f }
