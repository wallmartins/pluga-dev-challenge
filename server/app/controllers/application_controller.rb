# app/controllers/application_controller.rb
class ApplicationController < ActionController::API
  rescue_from Exceptions::ApiError, with: :handle_api_error
  rescue_from ActiveRecord::RecordNotFound, with: :handle_not_found
  rescue_from ActionController::ParameterMissing, with: :handle_parameter_missing
  rescue_from StandardError, with: :handle_internal_error

  private

  def handle_api_error(exception)
    log_error(exception)
    render json: ErrorSerializer.new(
      exception: exception,
      controller: self,
      action: action_name
    ).as_json, status: exception.status
  end

  def handle_not_found(_exception)
    error = Exceptions::NotFoundError.new(resource: controller_name.classify)
    render json: ErrorSerializer.new(
      exception: error,
      controller: self,
      action: action_name
    ).as_json, status: error.status
  end

  def handle_parameter_missing(exception)
    error = Exceptions::BadRequestError.new(
      "Parâmetro obrigatório ausente: #{exception.param}",
      details: { parameter: exception.param }
    )
    render json: ErrorSerializer.new(
      exception: error,
      controller: self,
      action: action_name
    ).as_json, status: error.status
  end

  def handle_internal_error(exception)
    error = Exceptions::InternalServerError.new(
      "Ocorreu um erro inesperado. Por favor, tente novamente."
    )
    log_error(exception)
    render json: ErrorSerializer.new(
      exception: error,
      controller: self,
      action: action_name
    ).as_json, status: error.status
  end

  def log_error(exception)
    Rails.logger.error(
      "[#{exception.class}] #{exception.message}\n" \
      "→ Controller: #{controller_name}##{action_name}\n" \
      "→ Backtrace: #{exception.backtrace&.first(5)&.join("\n")}\n"
    )
  end
end
