# frozen_string_literal: true

class SummarizeSummaryJob < ApplicationJob
  queue_as :default

  def perform(summary_id)
    summary = Summary.find(summary_id)
    generated_summary = GenerateSummaries.call(summary.original_post)

    summary.update!(
      summary: generated_summary,
      status: "completed"
    )

  rescue ValidationError => e
    update_summary_on_error(summary, "failed", e.message)
    Rails.logger.error("Validation error while summarizing ID=#{summary_id}: #{e.message}")
    raise e
  rescue BadRequestError => e
    update_summary_on_error(summary, "failed", "O texto contém padrões suspeitos ou é inválido. Por favor, revise e tente novamente.")
    Rails.logger.error("Bad request while summarizing ID=#{summary_id}: #{e.message}")
    raise e
  rescue ExternalServiceError => e
    update_summary_on_error(summary, "failed", "O serviço de resumo está temporariamente indisponível. Por favor, tente novamente em alguns instantes.")
    Rails.logger.error("External service error while summarizing ID=#{summary_id}: #{e.message}")
    raise e
  rescue ApiError => e
    update_summary_on_error(summary, "failed", e.message)
    Rails.logger.error("API error while summarizing ID=#{summary_id}: #{e.message}")
    raise e
  rescue => e
    update_summary_on_error(summary, "failed", "Ocorreu um erro inesperado ao processar o resumo. Por favor, tente novamente.")
    Rails.logger.error("Unexpected error in SummarizeSummaryJob ID=#{summary_id}: #{e.message}")
    raise InternalServerError.new(
      "Falha ao processar resumo #{summary_id}",
      details: e.message
    )
  end

  private

  def update_summary_on_error(summary, status, message)
    summary.update!(status: status, summary: message) if summary.is_a?(Summary)
  end
end
