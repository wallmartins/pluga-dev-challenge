module JsonHelper
  def json
    JSON.parse(response.body, symbolize_names: true)
  end
end

RSpec.configure do |config|
  config.include JsonHelper, type: :request
end
