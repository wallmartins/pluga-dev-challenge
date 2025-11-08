class GenerateSummaries
  MIN_TEXT_LENGTH = 30

  def self.call(text)
    if text.nil? || text.strip.empty?
      raise Exceptions::ValidationError.new(
        entity: "Summary",
        message: "The original post cannot be empty.",
        details: { original_post: ["must be provided"] }
      )
    end

    if text.length < MIN_TEXT_LENGTH
      raise Exceptions::ValidationError.new(
        entity: "Summary",
        message: "The original post must have at least #{MIN_TEXT_LENGTH} characters.",
        details: { original_post: ["is too short (minimum is #{MIN_TEXT_LENGTH} characters)"] }
      )
    end

    SummarizeTextService.new(text).call
  end
end
