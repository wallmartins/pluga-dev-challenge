# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ApiError do
  describe "initialization" do
    it "stores message as exception message" do
      error = described_class.new("Test error")
      expect(error.message).to eq("Test error")
    end

    it "sets status code with default 500" do
      error = described_class.new("Test error")
      expect(error.status).to eq(500)
    end

    it "sets custom status code" do
      error = described_class.new("Test error", status: 400)
      expect(error.status).to eq(400)
    end

    it "sets error_code with default based on status" do
      error = described_class.new("Test error", status: 400)
      expect(error.error_code).to eq("bad_request")
    end

    it "sets custom error_code" do
      error = described_class.new("Test error", status: 500, error_code: "custom_error")
      expect(error.error_code).to eq("custom_error")
    end

    it "stores details" do
      details = { field: "value" }
      error = described_class.new("Test error", details: details)
      expect(error.details).to eq(details)
    end

    it "stores context" do
      context = { user_id: 123 }
      error = described_class.new("Test error", context: context)
      expect(error.context).to eq(context)
    end

    it "stores nil for details when not provided" do
      error = described_class.new("Test error")
      expect(error.details).to be_nil
    end
  end

  describe "default_error_code" do
    it "returns 'bad_request' for status 400" do
      error = described_class.new("Test", status: 400)
      expect(error.error_code).to eq("bad_request")
    end

    it "returns 'not_found' for status 404" do
      error = described_class.new("Test", status: 404)
      expect(error.error_code).to eq("not_found")
    end

    it "returns 'unprocessable_entity' for status 422" do
      error = described_class.new("Test", status: 422)
      expect(error.error_code).to eq("unprocessable_entity")
    end

    it "returns 'external_service_error' for status 502" do
      error = described_class.new("Test", status: 502)
      expect(error.error_code).to eq("external_service_error")
    end

    it "returns 'internal_server_error' for other statuses" do
      error = described_class.new("Test", status: 503)
      expect(error.error_code).to eq("internal_server_error")
    end

    it "returns 'internal_server_error' for default 500" do
      error = described_class.new("Test")
      expect(error.error_code).to eq("internal_server_error")
    end
  end

  describe "inheritance" do
    it "is a StandardError" do
      error = described_class.new("Test")
      expect(error).to be_a(StandardError)
    end

    it "can be caught as StandardError" do
      expect {
        raise described_class.new("Test")
      }.to raise_error(StandardError)
    end
  end
end

RSpec.describe BadRequestError do
  describe "initialization" do
    it "sets status to 400" do
      error = described_class.new("Invalid request")
      expect(error.status).to eq(400)
    end

    it "sets error_code to 'bad_request'" do
      error = described_class.new("Invalid request")
      expect(error.error_code).to eq("bad_request")
    end

    it "uses provided message" do
      error = described_class.new("Custom error message")
      expect(error.message).to eq("Custom error message")
    end

    it "uses default message when not provided" do
      error = described_class.new
      expect(error.message).to eq("A requisição é inválida ou está faltando parâmetros obrigatórios.")
    end

    it "stores details when provided" do
      details = { field: "name" }
      error = described_class.new("Error", details: details)
      expect(error.details).to eq(details)
    end
  end

  describe "inheritance" do
    it "is an ApiError" do
      error = described_class.new
      expect(error).to be_a(ApiError)
    end
  end
end

RSpec.describe NotFoundError do
  describe "initialization" do
    it "sets status to 404" do
      error = described_class.new(resource: "User")
      expect(error.status).to eq(404)
    end

    it "sets error_code to 'not_found'" do
      error = described_class.new(resource: "User")
      expect(error.error_code).to eq("not_found")
    end

    it "includes resource name in message" do
      error = described_class.new(resource: "Post")
      expect(error.message).to eq("Post não encontrado.")
    end

    it "uses default resource name when not provided" do
      error = described_class.new
      expect(error.message).to eq("Recurso não encontrado.")
    end

    it "stores details when provided" do
      details = { id: 123 }
      error = described_class.new(resource: "User", details: details)
      expect(error.details).to eq(details)
    end
  end

  describe "inheritance" do
    it "is an ApiError" do
      error = described_class.new
      expect(error).to be_a(ApiError)
    end
  end
end

RSpec.describe ValidationError do
  describe "initialization" do
    it "sets status to 422" do
      error = described_class.new
      expect(error.status).to eq(422)
    end

    it "sets error_code to 'unprocessable_entity'" do
      error = described_class.new
      expect(error.error_code).to eq("unprocessable_entity")
    end

    it "uses custom message when provided" do
      error = described_class.new(entity: "User", message: "Email is invalid")
      expect(error.message).to eq("Email is invalid")
    end

    it "generates message from entity when message not provided" do
      error = described_class.new(entity: "Summary")
      expect(error.message).to eq("Validação do Summary falhou. Por favor, verifique os dados fornecidos.")
    end

    it "uses default entity name when not provided" do
      error = described_class.new
      expect(error.message).to eq("Validação do Registro falhou. Por favor, verifique os dados fornecidos.")
    end

    it "stores details when provided" do
      details = { original_post: [ "is too short" ] }
      error = described_class.new(entity: "Summary", details: details)
      expect(error.details).to eq(details)
    end
  end

  describe "inheritance" do
    it "is an ApiError" do
      error = described_class.new
      expect(error).to be_a(ApiError)
    end
  end
end

RSpec.describe InternalServerError do
  describe "initialization" do
    it "sets status to 500" do
      error = described_class.new("Server error")
      expect(error.status).to eq(500)
    end

    it "sets error_code to 'internal_server_error'" do
      error = described_class.new("Server error")
      expect(error.error_code).to eq("internal_server_error")
    end

    it "uses provided message" do
      error = described_class.new("Database connection failed")
      expect(error.message).to eq("Database connection failed")
    end

    it "uses default message when not provided" do
      error = described_class.new
      expect(error.message).to eq("Ocorreu um erro inesperado ao processar sua requisição.")
    end

    it "stores details when provided" do
      details = { error: "connection_timeout" }
      error = described_class.new("Error", details: details)
      expect(error.details).to eq(details)
    end
  end

  describe "inheritance" do
    it "is an ApiError" do
      error = described_class.new
      expect(error).to be_a(ApiError)
    end
  end
end

RSpec.describe ExternalServiceError do
  describe "initialization" do
    it "sets status to 502" do
      error = described_class.new(service_name: "Gemini API")
      expect(error.status).to eq(502)
    end

    it "sets error_code to 'external_service_error'" do
      error = described_class.new(service_name: "Gemini API")
      expect(error.error_code).to eq("external_service_error")
    end

    it "includes service name in default message" do
      error = described_class.new(service_name: "Payment Gateway")
      expect(error.message).to eq("Payment Gateway está temporariamente indisponível. Tente novamente mais tarde.")
    end

    it "uses custom message when provided" do
      error = described_class.new(service_name: "API", message: "Connection timeout")
      expect(error.message).to eq("Connection timeout")
    end

    it "uses default service name when not provided" do
      error = described_class.new
      expect(error.message).to eq("Serviço externo está temporariamente indisponível. Tente novamente mais tarde.")
    end

    it "stores details when provided" do
      details = { http_status: 503, retry_after: 60 }
      error = described_class.new(service_name: "API", details: details)
      expect(error.details).to eq(details)
    end
  end

  describe "inheritance" do
    it "is an ApiError" do
      error = described_class.new
      expect(error).to be_a(ApiError)
    end
  end
end

RSpec.describe "Exception error codes" do
  describe "all exceptions have error_code attribute" do
    let(:exceptions_to_test) do
      [
        BadRequestError.new,
        NotFoundError.new,
        ValidationError.new,
        InternalServerError.new,
        ExternalServiceError.new
      ]
    end

    it "all have error_code attribute" do
      exceptions_to_test.each do |error|
        expect(error).to respond_to(:error_code)
        expect(error.error_code).to be_a(String)
        expect(error.error_code).not_to be_empty
      end
    end
  end

  describe "all exceptions have status attribute" do
    let(:exceptions_to_test) do
      [
        BadRequestError.new,
        NotFoundError.new,
        ValidationError.new,
        InternalServerError.new,
        ExternalServiceError.new
      ]
    end

    it "all have status attribute" do
      exceptions_to_test.each do |error|
        expect(error).to respond_to(:status)
        expect(error.status).to be_an(Integer)
        expect(error.status).to be >= 400
        expect(error.status).to be < 600
      end
    end
  end

  describe "all exceptions have message attribute" do
    let(:exceptions_to_test) do
      [
        BadRequestError.new,
        NotFoundError.new,
        ValidationError.new,
        InternalServerError.new,
        ExternalServiceError.new
      ]
    end

    it "all have message attribute" do
      exceptions_to_test.each do |error|
        expect(error).to respond_to(:message)
        expect(error.message).to be_a(String)
        expect(error.message).not_to be_empty
      end
    end
  end
end

RSpec.describe "Exception attributes accessibility" do
  it "status is readable" do
    error = BadRequestError.new("Error")
    expect(error.status).to eq(400)
  end

  it "error_code is readable" do
    error = BadRequestError.new("Error")
    expect(error.error_code).to eq("bad_request")
  end

  it "details is readable" do
    details = { field: "value" }
    error = BadRequestError.new("Error", details: details)
    expect(error.details).to eq(details)
  end

  it "context is readable via ApiError" do
    context = { user_id: 1 }
    error = ApiError.new("Error", context: context)
    expect(error.context).to eq(context)
  end

  it "status is not writable (private)" do
    error = BadRequestError.new("Error")
    expect {
      error.status = 404
    }.to raise_error(NoMethodError)
  end

  it "error_code is not writable (private)" do
    error = BadRequestError.new("Error")
    expect {
      error.error_code = "custom"
    }.to raise_error(NoMethodError)
  end

  it "details is not writable (private)" do
    error = BadRequestError.new("Error")
    expect {
      error.details = {}
    }.to raise_error(NoMethodError)
  end

  it "context is not writable (private)" do
    error = ApiError.new("Error", context: {})
    expect {
      error.context = {}
    }.to raise_error(NoMethodError)
  end
end
