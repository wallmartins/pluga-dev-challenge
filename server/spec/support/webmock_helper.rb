require 'webmock/rspec'

RSpec.configure do |config|
  config.include WebMock::API, type: :client

  config.before(:suite) do
    WebMock.disable_net_connect!(allow_localhost: true)
  end
end
