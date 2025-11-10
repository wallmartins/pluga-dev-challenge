# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ApplicationController do
  describe "#handle_api_error" do
    it "renders error with correct status from exception" do
      controller = SummariesController.new
      exception = Exceptions::BadRequestError.new("Invalid input")

      expect(controller).to receive(:render) do |args|
        expect(args[:status]).to eq(400)
        expect(args[:json][:error][:code]).to eq('bad_request')
        expect(args[:json][:error][:message]).to eq('Invalid input')
        expect(args[:json][:meta]).to have_key(:request_id)
      end

      controller.send(:handle_api_error, exception)
    end

    it "uses ErrorSerializer to format response" do
      controller = SummariesController.new
      exception = Exceptions::ValidationError.new(entity: "Test")

      expect(controller).to receive(:render) do |args|
        expect(args[:json]).to have_key(:error)
        expect(args[:json]).to have_key(:meta)
      end

      controller.send(:handle_api_error, exception)
    end

    it "logs the error before rendering" do
      controller = SummariesController.new
      exception = Exceptions::BadRequestError.new("Log test")
      allow(Rails.logger).to receive(:error)
      allow(controller).to receive(:render)

      controller.send(:handle_api_error, exception)

      expect(Rails.logger).to have_received(:error).with(
        /\[Exceptions::BadRequestError\] Log test/
      )
    end
  end

  describe "#handle_not_found" do
    it "renders 404 NotFoundError response" do
      controller = SummariesController.new

      expect(controller).to receive(:render) do |args|
        expect(args[:status]).to eq(404)
        expect(args[:json][:error][:code]).to eq('not_found')
        expect(args[:json][:error][:message]).to match(/Summary não encontrado/)
      end

      controller.send(:handle_not_found, nil)
    end
  end

  describe "#handle_parameter_missing" do
    it "renders 400 BadRequestError with parameter details" do
      controller = SummariesController.new
      exception = ActionController::ParameterMissing.new(:email)

      expect(controller).to receive(:render) do |args|
        expect(args[:status]).to eq(400)
        expect(args[:json][:error][:code]).to eq('bad_request')
        expect(args[:json][:error][:message]).to match(/Parâmetro obrigatório ausente: email/)
        expect(args[:json][:error][:details][:parameter]).to eq(:email)
      end

      controller.send(:handle_parameter_missing, exception)
    end
  end

  describe "#handle_internal_error" do
    it "renders 500 InternalServerError" do
      controller = SummariesController.new
      exception = StandardError.new("Database connection failed")

      expect(controller).to receive(:render) do |args|
        expect(args[:status]).to eq(500)
        expect(args[:json][:error][:code]).to eq('internal_server_error')
        expect(args[:json][:error][:message]).to eq('Ocorreu um erro inesperado. Por favor, tente novamente.')
      end

      controller.send(:handle_internal_error, exception)
    end

    it "logs the error" do
      controller = SummariesController.new
      exception = StandardError.new("Test error")

      allow(controller).to receive(:render)
      allow(Rails.logger).to receive(:error)

      controller.send(:handle_internal_error, exception)

      expect(Rails.logger).to have_received(:error).with(
        /\[StandardError\] Test error/
      )
    end
  end

  describe "#log_error" do
    it "logs error with exception class, message, and context" do
      controller = SummariesController.new
      exception = Exceptions::BadRequestError.new("Test message")

      allow(Rails.logger).to receive(:error)

      controller.send(:log_error, exception)

      expect(Rails.logger).to have_received(:error).with(
        /\[Exceptions::BadRequestError\] Test message/
      )
    end

    it "includes controller and action in log" do
      controller = SummariesController.new
      exception = StandardError.new("Error")

      allow(Rails.logger).to receive(:error)
      allow(controller).to receive(:controller_name).and_return('summaries')
      allow(controller).to receive(:action_name).and_return('show')

      controller.send(:log_error, exception)

      expect(Rails.logger).to have_received(:error).with(
        /Controller: summaries#show/
      )
    end

    it "includes backtrace in log" do
      controller = SummariesController.new
      exception = StandardError.new("Error")

      allow(Rails.logger).to receive(:error)

      controller.send(:log_error, exception)

      expect(Rails.logger).to have_received(:error).with(
        /Backtrace:/
      )
    end

    it "handles exception with nil backtrace" do
      controller = SummariesController.new
      exception = StandardError.new("Error")
      allow(exception).to receive(:backtrace).and_return(nil)
      allow(Rails.logger).to receive(:error)

      controller.send(:log_error, exception)

      expect(Rails.logger).to have_received(:error).with(
        /Backtrace:/
      )
    end

    it "handles exception with empty backtrace array" do
      controller = SummariesController.new
      exception = StandardError.new("Error")
      allow(exception).to receive(:backtrace).and_return([])
      allow(Rails.logger).to receive(:error)

      controller.send(:log_error, exception)

      expect(Rails.logger).to have_received(:error)
    end
  end

  describe "error context information" do
    it "includes controller name in error context" do
      controller = SummariesController.new
      exception = Exceptions::BadRequestError.new("Test")

      expect(controller).to receive(:render) do |args|
        expect(args[:json][:error][:context][:controller]).to eq('SummariesController')
      end

      controller.send(:handle_api_error, exception)
    end

    it "includes action name in error context" do
      controller = SummariesController.new
      exception = Exceptions::BadRequestError.new("Test")
      allow(controller).to receive(:action_name).and_return('create')

      expect(controller).to receive(:render) do |args|
        expect(args[:json][:error][:context][:action]).to eq('create')
      end

      controller.send(:handle_api_error, exception)
    end

    it "includes exception class name in error context" do
      controller = SummariesController.new
      exception = Exceptions::ValidationError.new(entity: "User")

      expect(controller).to receive(:render) do |args|
        expect(args[:json][:error][:context][:exception_class]).to eq('Exceptions::ValidationError')
      end

      controller.send(:handle_api_error, exception)
    end
  end

  describe "error handling integration" do
    it "handles all exception types via their specific handlers" do
      controller = SummariesController.new

      # Test that handler methods are defined and callable
      expect(controller.respond_to?(:handle_api_error, true)).to be true
      expect(controller.respond_to?(:handle_not_found, true)).to be true
      expect(controller.respond_to?(:handle_parameter_missing, true)).to be true
      expect(controller.respond_to?(:handle_internal_error, true)).to be true
      expect(controller.respond_to?(:log_error, true)).to be true
    end
  end
end
