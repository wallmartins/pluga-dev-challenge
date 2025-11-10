# frozen_string_literal: true
class Summary < ApplicationRecord
  validates :original_post, presence: true, length: { minimum: 30 }
  validates :status, inclusion: { in: %w[pending completed failed] }

  enum :status, { pending: "pending", completed: "completed", failed: "failed" }
end
