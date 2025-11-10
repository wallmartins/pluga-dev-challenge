# frozen_string_literal: true

class SummarizeTextService
  def initialize(text)
    @text = text
  end

  def call
    Gemini::Client.summarize(@text)
  rescue ApiError => e
    raise e
  rescue => e
    raise ExternalServiceError.new(
      service_name: "Gemini API",
      message: "Erro inesperado durante a sumarização.",
      details: e.message
    )
  end
end
