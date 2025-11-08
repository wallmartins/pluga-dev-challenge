class SummarySerializer
  def initialize(summary, detailed: false)
    @summary = summary
    @detailed = detailed
  end

  def as_json(*)
    data = {
      id: @summary.id,
      status: @summary.status,
      summary: @summary.summary,
      created_at: @summary.created_at,
      original_post: @summary.original_post
    }

    data
  end
end
