# frozen_string_literal: true

require "json"

module Gemini
  class ResponseHandler
    def initialize(response)
      @response = response
    end

    def handle!
      case @response
      when Net::HTTPSuccess
        parse_success
      when Net::HTTPBadRequest
        client_error
      when Net::HTTPClientError
        raise Exceptions::ExternalServiceError.new(service_name: "Gemini API", message: "Erro do cliente (#{@response.code}).")
      when Net::HTTPServerError
        server_error
      else
        raise Exceptions::ExternalServiceError.new(service_name: "Gemini API", message: "Resposta inesperada (#{@response.code}).")
      end
    end

    private

    def parse_success
      parsed = JSON.parse(@response.body)
      text = parsed.dig("candidates", 0, "content", "parts", 0, "text")

      if text.blank? || text.match?(/ignore|instruction/i)
        raise Exceptions::ExternalServiceError.new(
          service_name: "Gemini API",
          message: "Resposta inesperada ou potencialmente insegura."
        )
      end

      text.strip
    rescue JSON::ParserError => e
      raise Exceptions::ExternalServiceError.new(
        service_name: "Gemini API",
        message: "Resposta malformada do Gemini",
        details: e.message
      )
    end

    def client_error
      parsed = JSON.parse(@response.body) rescue {}
      message = parsed.dig("error", "message") || "Requisição inválida enviada à API Gemini."
      raise Exceptions::BadRequestError.new(
        "Gemini API rejeitou a requisição: #{message}",
        details: { code: @response.code, body: parsed }
      )
    end

    def server_error
      parsed = JSON.parse(@response.body) rescue {}
      message = parsed.dig("error", "message") || "Serviço Gemini indisponível."
      raise Exceptions::ExternalServiceError.new(
        service_name: "Gemini API",
        message: message,
        details: { code: @response.code, body: parsed }
      )
    end
  end
end
