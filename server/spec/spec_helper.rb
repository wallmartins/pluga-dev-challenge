# frozen_string_literal: true

require 'spec_helper'

ENV['RAILS_ENV'] ||= 'test'
ENV['DISABLE_SPRING'] = '1'

require 'simplecov'
SimpleCov.start 'rails' do
  enable_coverage :branch
  add_filter '/spec/'
  add_filter '/config/'
  add_filter '/vendor/'
  track_files 'app/**/*.rb'
end

puts "SimpleCov started for coverage analysis"

require_relative '../config/environment'

abort("The Rails environment is running in production mode!") if Rails.env.production?

require 'rspec/rails'
require 'shoulda/matchers'

Rails.root.glob('spec/support/**/*.rb').sort_by(&:to_s).each { |f| require f }

begin
  ActiveRecord::Migration.maintain_test_schema!
rescue ActiveRecord::PendingMigrationError => e
  abort e.to_s.strip
end

RSpec.configure do |config|
  config.include FactoryBot::Syntax::Methods
  config.include ActiveJob::TestHelper
  
  config.fixture_paths = [
    Rails.root.join('spec/fixtures')
  ]
  
  config.use_transactional_fixtures = true
  
  config.filter_rails_from_backtrace!
end

Shoulda::Matchers.configure do |config|
  config.integrate do |with|
    with.test_framework :rspec
    with.library :rails
  end
end