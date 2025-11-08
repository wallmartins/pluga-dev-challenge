# frozen_string_literal: true

require "net/http"
require "json"

module Gemini
  class HttpClient
    GEMINI_URL = "https://generativelanguage.googleapis.com/v1beta/models".freeze

    def initialize(model:, api_key:)
      @model = model
      @api_key = api_key
    end

    def post(body)
      uri = URI("#{GEMINI_URL}/#{@model}:generateContent?key=#{@api_key}")
      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = true
      http.open_timeout = 5
      http.read_timeout = 20

      request = Net::HTTP::Post.new(uri.request_uri, { "Content-Type" => "application/json" })
      request.body = body.to_json

      http.request(request)
    end
  end
end
