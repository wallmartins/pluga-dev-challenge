# app/controllers/summaries_controller.rb
class SummariesController < ApplicationController
  def index
    summaries = Summary.order(created_at: :desc)
    render json: summaries
  end

  def show
    summary = Summary.find(params[:id])
    render json: summary
  end

  def create
    summary = Summary.new(summary_params.merge(status: "pending"))

    if summary.save
      SummarizeSummaryJob.perform_later(summary.id)
      render json: summary, status: :created
    else
      raise Exceptions::ValidationError.new(
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
