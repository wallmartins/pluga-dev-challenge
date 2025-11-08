# frozen_string_literal: true

module Gemini
  class Client
    def self.summarize(text)
      model = ENV.fetch("GEMINI_MODEL", "gemini-2.5-flash")
      api_key = ENV.fetch("GEMINI_KEY")

      request_body = Gemini::RequestBuilder.new(text).build!
      response = Gemini::HttpClient.new(model: model, api_key: api_key).post(request_body)
      Gemini::ResponseHandler.new(response).handle!
    rescue Exceptions::ApiError => e
      raise e
    rescue => e
      raise Exceptions::ExternalServiceError.new(
        service_name: "Gemini API",
        message: "Erro inesperado ao chamar Gemini",
        details: e.message
      )
    end
  end
end
