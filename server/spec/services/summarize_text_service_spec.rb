# frozen_string_literal: true

require 'rails_helper'

RSpec.describe SummarizeTextService do
  let(:text) { Faker::Lorem.paragraph(sentence_count: 5) }
  let(:expected_summary) { Faker::Lorem.paragraph(sentence_count: 2) }

  describe "#initialize" do
    it "stores the text parameter" do
      service = described_class.new(text)
      expect(service.instance_variable_get(:@text)).to eq(text)
    end
  end

  describe "#call" do
    context "when GeminiClient returns successfully" do
      it "returns summary from GeminiClient" do
        allow(Gemini::Client).to receive(:summarize).with(text).and_return(expected_summary)

        service = described_class.new(text)
        result = service.call

        expect(result).to eq(expected_summary)
      end

      it "calls GeminiClient.summarize with correct text" do
        allow(Gemini::Client).to receive(:summarize).and_return(expected_summary)

        described_class.new(text).call

        expect(Gemini::Client).to have_received(:summarize).with(text).once
      end
    end

    context "when GeminiClient raises ApiError" do
      it "propagates BadRequestError" do
        error = Exceptions::BadRequestError.new("Invalid request")
        allow(Gemini::Client).to receive(:summarize).and_raise(error)

        service = described_class.new(text)

        expect {
          service.call
        }.to raise_error(Exceptions::BadRequestError)
      end

      it "propagates ExternalServiceError" do
        error = Exceptions::ExternalServiceError.new(service_name: "Gemini API")
        allow(Gemini::Client).to receive(:summarize).and_raise(error)

        expect {
          described_class.new(text).call
        }.to raise_error(Exceptions::ExternalServiceError)
      end

      it "propagates ValidationError" do
        error = Exceptions::ValidationError.new(entity: "Summary")
        allow(Gemini::Client).to receive(:summarize).and_raise(error)

        expect {
          described_class.new(text).call
        }.to raise_error(Exceptions::ValidationError)
      end
    end

    context "when GeminiClient raises unexpected error" do
      it "wraps error in ExternalServiceError" do
        allow(Gemini::Client).to receive(:summarize).and_raise(StandardError, "Network error")

        service = described_class.new(text)

        expect {
          service.call
        }.to raise_error(Exceptions::ExternalServiceError) do |error|
          expect(error.message).to include("Erro inesperado")
          expect(error.details).to include("Network error")
        end
      end

      it "preserves original exception message in details" do
        original_message = "Database timeout"
        allow(Gemini::Client).to receive(:summarize).and_raise(StandardError, original_message)

        expect {
          described_class.new(text).call
        }.to raise_error(Exceptions::ExternalServiceError) do |error|
          expect(error.details).to eq(original_message)
        end
      end

      it "wraps RuntimeError" do
        allow(Gemini::Client).to receive(:summarize).and_raise(RuntimeError, "System error")

        expect {
          described_class.new(text).call
        }.to raise_error(Exceptions::ExternalServiceError)
      end
    end

    context "with empty text" do
      it "passes empty text to GeminiClient" do
        allow(Gemini::Client).to receive(:summarize).and_return("Summary")

        described_class.new("").call

        expect(Gemini::Client).to have_received(:summarize).with("")
      end
    end

    context "with nil text" do
      it "passes nil to GeminiClient" do
        allow(Gemini::Client).to receive(:summarize).and_return("Summary")

        described_class.new(nil).call

        expect(Gemini::Client).to have_received(:summarize).with(nil)
      end
    end

    context "with very long text" do
      it "handles long text correctly" do
        long_text = Faker::Lorem.paragraphs(number: 50).join("\n\n")
        allow(Gemini::Client).to receive(:summarize).and_return(expected_summary)

        service = described_class.new(long_text)
        result = service.call

        expect(result).to eq(expected_summary)
        expect(Gemini::Client).to have_received(:summarize).with(long_text)
      end
    end

    context "with special characters" do
      it "handles text with special characters" do
        special_text = "Text with special chars: !@#$%^&*()"
        allow(Gemini::Client).to receive(:summarize).and_return(expected_summary)

        result = described_class.new(special_text).call

        expect(result).to eq(expected_summary)
        expect(Gemini::Client).to have_received(:summarize).with(special_text)
      end
    end

    context "with unicode characters" do
      it "handles unicode text" do
        unicode_text = "Texto com acentuação: Olá, mundo! 你好"
        allow(Gemini::Client).to receive(:summarize).and_return(expected_summary)

        result = described_class.new(unicode_text).call

        expect(result).to eq(expected_summary)
      end
    end

    context "with whitespace only" do
      it "passes whitespace text to GeminiClient" do
        whitespace_text = "   \n\t  "
        allow(Gemini::Client).to receive(:summarize).and_return(expected_summary)

        result = described_class.new(whitespace_text).call

        expect(result).to eq(expected_summary)
        expect(Gemini::Client).to have_received(:summarize).with(whitespace_text)
      end
    end
  end

  describe "#initialize" do
    context "with various input types" do
      it "accepts string text" do
        service = described_class.new("String text")
        expect(service.instance_variable_get(:@text)).to eq("String text")
      end

      it "accepts empty string" do
        service = described_class.new("")
        expect(service.instance_variable_get(:@text)).to eq("")
      end

      it "accepts nil" do
        service = described_class.new(nil)
        expect(service.instance_variable_get(:@text)).to be_nil
      end
    end
  end
end
