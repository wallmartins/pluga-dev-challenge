# frozen_string_literal: true
# app/serializers/error_serializer.rb
class ErrorSerializer
  def initialize(exception:, controller:, action:)
    @exception = exception
    @controller = controller
    @action = action
  end

  def as_json
    {
      error: {
        code: error_code,
        message: @exception.message,
        details: format_details,
        context: context_info
      },
      meta: {
        timestamp: Time.current.iso8601,
        request_id: request_id
      }
    }.compact
  end

  private

  def error_code
    if @exception.respond_to?(:error_code)
      @exception.error_code
    else
      "internal_server_error"
    end
  end

  def format_details
    details = @exception.respond_to?(:details) ? @exception.details : nil
    return details if details.present?

    if @exception.is_a?(ActiveRecord::RecordInvalid)
      @exception.record.errors.full_messages
    else
      nil
    end
  end

  def context_info
    {
      controller: @controller.class.name,
      action: @action,
      exception_class: @exception.class.name
    }
  end

  def request_id
    Thread.current[:request_id] || SecureRandom.uuid
  end
end
