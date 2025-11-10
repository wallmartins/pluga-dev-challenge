# app/exceptions/api_error.rb
module Exceptions
  class ApiError < StandardError
    attr_reader :status, :error_code, :details, :context

    def initialize(message, status: 500, error_code: nil, details: nil, context: nil)
      super(message)
      @status = status
      @error_code = error_code || default_error_code(status)
      @details = details
      @context = context
    end

    private

    def default_error_code(status)
      case status
      when 400 then "bad_request"
      when 404 then "not_found"
      when 422 then "unprocessable_entity"
      when 502 then "external_service_error"
      else "internal_server_error"
      end
    end
  end

  class NotFoundError < ApiError
    def initialize(resource: "Recurso", details: nil)
      super(
        "#{resource} não encontrado.",
        status: 404,
        details:
      )
    end
  end

  class ValidationError < ApiError
    def initialize(entity: "Registro", message: nil, details: nil)
      super(
        message || "Validação do #{entity} falhou. Por favor, verifique os dados fornecidos.",
        status: 422,
        details:
      )
    end
  end

  class BadRequestError < ApiError
    def initialize(message = "A requisição é inválida ou está faltando parâmetros obrigatórios.", details: nil)
      super(message, status: 400, details:)
    end
  end

  class InternalServerError < ApiError
    def initialize(message = "Ocorreu um erro inesperado ao processar sua requisição.", details: nil)
      super(message, status: 500, details:)
    end
  end

  class ExternalServiceError < ApiError
    def initialize(service_name: "Serviço externo", message: nil, details: nil)
      super(
        message || "#{service_name} está temporariamente indisponível. Tente novamente mais tarde.",
        status: 502,
        error_code: "external_service_error",
        details:
      )
    end
  end
end
