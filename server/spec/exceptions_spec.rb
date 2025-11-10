# frozen_string_literal: true

require 'rails_helper'

require_relative '../app/exceptions'

RSpec.describe Exceptions do
  describe "module definition" do
    it "defines the Exceptions module" do
      expect(defined?(Exceptions)).to eq("constant")
    end

    it "is a Module" do
      expect(Exceptions).to be_a(Module)
    end
  end

  describe "exception classes availability" do
    it "loads ApiError class" do
      expect(Exceptions::ApiError).to be_a(Class)
    end

    it "loads BadRequestError class" do
      expect(Exceptions::BadRequestError).to be_a(Class)
    end

    it "loads NotFoundError class" do
      expect(Exceptions::NotFoundError).to be_a(Class)
    end

    it "loads ValidationError class" do
      expect(Exceptions::ValidationError).to be_a(Class)
    end

    it "loads InternalServerError class" do
      expect(Exceptions::InternalServerError).to be_a(Class)
    end

    it "loads ExternalServiceError class" do
      expect(Exceptions::ExternalServiceError).to be_a(Class)
    end
  end

  describe "inheritance hierarchy" do
    let(:exception_classes) do
      [
        Exceptions::ApiError,
        Exceptions::BadRequestError,
        Exceptions::NotFoundError,
        Exceptions::ValidationError,
        Exceptions::InternalServerError,
        Exceptions::ExternalServiceError
      ]
    end

    it "all exceptions inherit from StandardError" do
      exception_classes.each do |klass|
        expect(klass < StandardError).to be true
      end
    end

    it "all subclasses inherit from ApiError" do
      subclasses = exception_classes[1..-1]
      subclasses.each do |klass|
        expect(klass < Exceptions::ApiError).to be true
      end
    end

    it "ApiError is directly a StandardError subclass" do
      expect(Exceptions::ApiError < StandardError).to be true
    end
  end

  describe "exception instantiation" do
    it "can instantiate ApiError" do
      error = Exceptions::ApiError.new("Test")
      expect(error).to be_a(Exceptions::ApiError)
    end

    it "can instantiate BadRequestError" do
      error = Exceptions::BadRequestError.new
      expect(error).to be_a(Exceptions::BadRequestError)
    end

    it "can instantiate NotFoundError" do
      error = Exceptions::NotFoundError.new
      expect(error).to be_a(Exceptions::NotFoundError)
    end

    it "can instantiate ValidationError" do
      error = Exceptions::ValidationError.new
      expect(error).to be_a(Exceptions::ValidationError)
    end

    it "can instantiate InternalServerError" do
      error = Exceptions::InternalServerError.new
      expect(error).to be_a(Exceptions::InternalServerError)
    end

    it "can instantiate ExternalServiceError" do
      error = Exceptions::ExternalServiceError.new
      expect(error).to be_a(Exceptions::ExternalServiceError)
    end
  end
end
