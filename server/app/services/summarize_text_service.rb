class SummarizeTextService
  def initialize(text)
    @text = text
  end

  def call
    GeminiClient.summarize(@text)
  rescue Exceptions::ApiError => e
    raise e
  rescue => e
    raise Exceptions::ExternalServiceError.new(
      service_name: "Gemini API",
      message: "Unexpected error during summarization.",
      details: e.message
    )
  end
end
