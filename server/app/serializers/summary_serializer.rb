# frozen_string_literal: true

class SummarySerializer < ActiveModel::Serializer
  attributes :id, :status, :summary, :created_at, :original_post

  def initialize(object, detailed: false)
    super(object)
    @summary = object
    @detailed = detailed
  end

  def as_json(options = nil)
    {
      id: @summary.id,
      status: @summary.status,
      summary: @summary.summary,
      created_at: @summary.created_at,
      original_post: @summary.original_post
    }
  end
end
