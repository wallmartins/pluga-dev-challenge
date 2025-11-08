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
    def initialize(resource: "Resource", details: nil)
      super(
        "#{resource} could not be found.",
        status: 404,
        details:
      )
    end
  end

  class ValidationError < ApiError
    def initialize(entity: "Record", message: nil, details: nil)
      super(
        message || "#{entity} validation failed. Please check the provided data.",
        status: 422,
        details:
      )
    end
  end

  class BadRequestError < ApiError
    def initialize(message = "The request is invalid or missing required parameters.", details: nil)
      super(message, status: 400, details:)
    end
  end

  class InternalServerError < ApiError
    def initialize(message = "An unexpected error occurred while processing your request.", details: nil)
      super(message, status: 500, details:)
    end
  end

  class ExternalServiceError < ApiError
    def initialize(service_name: "External service", message: nil, details: nil)
      super(
        message || "#{service_name} is temporarily unavailable. Please try again later.",
        status: 502,
        error_code: "external_service_error",
        details:
      )
    end
  end
end
