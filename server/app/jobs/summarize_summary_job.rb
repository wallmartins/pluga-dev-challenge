class SummarizeSummaryJob < ApplicationJob
  queue_as :default

  def perform(summary_id)
    summary = nil
    summary = Summary.find(summary_id)
    generated_summary = GenerateSummaries.call(summary.original_post)

    summary.update!(
      summary: generated_summary,
      status: "completed"
    )

  rescue Exceptions::ValidationError => e
    if summary
      summary.update!(
        status: "failed",
        summary: e.message
      )
    end
    Rails.logger.error("Validation error while summarizing ID=#{summary_id}: #{e.message}")
    raise e
  rescue Exceptions::BadRequestError => e
    if summary
      summary.update!(
        status: "failed",
        summary: "O texto contém padrões suspeitos ou é inválido. Por favor, revise e tente novamente."
      )
    end
    Rails.logger.error("Bad request while summarizing ID=#{summary_id}: #{e.message}")
    raise e
  rescue Exceptions::ExternalServiceError => e
    if summary
      summary.update!(
        status: "failed",
        summary: "O serviço de resumo está temporariamente indisponível. Por favor, tente novamente em alguns instantes."
      )
    end
    Rails.logger.error("External service error while summarizing ID=#{summary_id}: #{e.message}")
    raise e
  rescue Exceptions::ApiError => e
    if summary
      summary.update!(
        status: "failed",
        summary: e.message
      )
    end
    Rails.logger.error("API error while summarizing ID=#{summary_id}: #{e.message}")
    raise e
  rescue => e
    if summary
      summary.update!(
        status: "failed",
        summary: "Ocorreu um erro inesperado ao processar o resumo. Por favor, tente novamente."
      )
    end
    Rails.logger.error("Unexpected error in SummarizeSummaryJob ID=#{summary_id}: #{e.message}")
    raise Exceptions::InternalServerError.new(
      "Falha ao processar resumo #{summary_id}",
      details: e.message
    )
  end
end
