class SummarySerializer < ActiveModel::Serializer
  attributes :id, :status, :summary, :created_at, :original_post
end
