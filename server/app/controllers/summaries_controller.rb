# frozen_string_literal: true

class SummariesController < ApplicationController
  def index
    summaries = Summary.order(created_at: :desc)
    serialized = summaries.map { |summary| SummarySerializer.new(summary).as_json }
    render json: serialized
  end

  def show
    summary = Summary.find(params[:id])
    render json: SummarySerializer.new(summary, detailed: true).as_json
  end

  def create
    summary = Summary.new(summary_params.merge(status: "pending"))

    if summary.save
      SummarizeSummaryJob.perform_later(summary.id)
      render json: SummarySerializer.new(summary).as_json, status: :created
    else
      raise ValidationError.new(
        entity: "Summary",
        message: "The original post must have at least 30 characters to generate a summary.",
        details: summary.errors.messages
      )
    end
  end

  private

  def summary_params
    params.require(:summary).permit(:original_post)
  end
end
