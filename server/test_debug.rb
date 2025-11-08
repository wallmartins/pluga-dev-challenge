require 'spec_helper'

ENV['RAILS_ENV'] ||= 'test'
require File.expand_path('../config/environment', __dir__)

RSpec.describe 'Debug' do
  it 'check get summaries' do
    get '/summaries'
    puts "\n=== RESPONSE STATUS ==="
    puts response.status
    puts "\n=== RESPONSE BODY ==="
    puts response.body
    puts "\n=== RESPONSE HEADERS ==="
    puts response.headers
  end
end
