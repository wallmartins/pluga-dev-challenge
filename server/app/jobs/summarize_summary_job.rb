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

  rescue Exceptions::ApiError => e
    summary.update!(status: "failed") if summary
    Rails.logger.error("Gemini API error while summarizing ID=#{summary_id}: #{e.message}")
    raise e
  rescue => e
    summary.update!(status: "failed") if summary
    Rails.logger.error("Unexpected error in SummarizeSummaryJob ID=#{summary_id}: #{e.message}")
    raise Exceptions::InternalServerError.new(
      "Failed to process summary #{summary_id}",
      details: e.message
    )
  end
end
