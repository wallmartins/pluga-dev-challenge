class GenerateSummaries
  MIN_TEXT_LENGTH = 30

  def self.call(text)
    if text.nil? || text.strip.empty?
      raise Exceptions::ValidationError.new(
        entity: "Resumo",
        message: "O texto não pode estar vazio.",
        details: { original_post: ["deve ser fornecido"] }
      )
    end

    if text.length < MIN_TEXT_LENGTH
      raise Exceptions::ValidationError.new(
        entity: "Resumo",
        message: "O texto deve ter pelo menos #{MIN_TEXT_LENGTH} caracteres.",
        details: { original_post: ["é muito curto (mínimo de #{MIN_TEXT_LENGTH} caracteres)"] }
      )
    end

    SummarizeTextService.new(text).call
  end
end
