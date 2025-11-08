Rswag::Api.configure do |c|
  c.openapi_root = Rails.root.join('swagger').to_s
  c.swagger_dry_run = false
end
