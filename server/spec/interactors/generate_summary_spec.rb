# frozen_string_literal: true

require 'rails_helper'

RSpec.describe GenerateSummaries do
  let(:valid_text) { Faker::Lorem.paragraph(sentence_count: 10) }
  let(:expected_summary) { Faker::Lorem.paragraph(sentence_count: 2) }

  describe ".call" do
    context "with valid text" do
      it "calls SummarizeTextService and returns summary" do
        allow_any_instance_of(SummarizeTextService).to receive(:call).and_return(expected_summary)

        result = described_class.call(valid_text)

        expect(result).to eq(expected_summary)
      end

      it "initializes SummarizeTextService with the text" do
        service_instance = instance_double(SummarizeTextService, call: expected_summary)
        allow(SummarizeTextService).to receive(:new).with(valid_text).and_return(service_instance)

        described_class.call(valid_text)

        expect(SummarizeTextService).to have_received(:new).with(valid_text)
      end
    end

    context "with nil text" do
      it "raises ValidationError" do
        expect {
          described_class.call(nil)
        }.to raise_error(Exceptions::ValidationError) do |error|
          expect(error.message).to include("não pode estar vazio")
          expect(error.status).to eq(422)
        end
      end

      it "includes validation details" do
        expect {
          described_class.call(nil)
        }.to raise_error(Exceptions::ValidationError) do |error|
          expect(error.details[:original_post]).to include("deve ser fornecido")
        end
      end
    end

    context "with empty string" do
      it "raises ValidationError" do
        expect {
          described_class.call("")
        }.to raise_error(Exceptions::ValidationError) do |error|
          expect(error.message).to include("não pode estar vazio")
        end
      end

      it "raises for whitespace-only strings" do
        expect {
          described_class.call("   \n  ")
        }.to raise_error(Exceptions::ValidationError)
      end
    end

    context "with text shorter than minimum length" do
      it "raises ValidationError for 29 character text" do
        short_text = "x" * 29

        expect {
          described_class.call(short_text)
        }.to raise_error(Exceptions::ValidationError) do |error|
          expect(error.message).to include("deve ter pelo menos 30 caracteres")
        end
      end

      it "includes minimum length in details" do
        short_text = Faker::Lorem.sentence(word_count: 3)

        expect {
          described_class.call(short_text)
        }.to raise_error(Exceptions::ValidationError) do |error|
          expect(error.details[:original_post]).to include(/mínimo de 30 caracteres/)
        end
      end

      it "accepts text with exactly 30 characters" do
        text_30_chars = "x" * 30
        allow_any_instance_of(SummarizeTextService).to receive(:call).and_return(expected_summary)

        result = described_class.call(text_30_chars)

        expect(result).to eq(expected_summary)
      end
    end

    context "with valid text at boundary" do
      it "accepts text with exactly 30 characters" do
        text_30_chars = Faker::Lorem.characters(number: 30)
        allow_any_instance_of(SummarizeTextService).to receive(:call).and_return(expected_summary)

        result = described_class.call(text_30_chars)

        expect(result).to eq(expected_summary)
      end

      it "accepts text longer than 30 characters" do
        long_text = Faker::Lorem.paragraph(sentence_count: 5)
        allow_any_instance_of(SummarizeTextService).to receive(:call).and_return(expected_summary)

        result = described_class.call(long_text)

        expect(result).to eq(expected_summary)
      end
    end

    context "when SummarizeTextService raises error" do
      it "propagates ExternalServiceError" do
        error = Exceptions::ExternalServiceError.new(service_name: "Gemini API")
        allow_any_instance_of(SummarizeTextService).to receive(:call).and_raise(error)

        expect {
          described_class.call(valid_text)
        }.to raise_error(Exceptions::ExternalServiceError)
      end

      it "propagates BadRequestError" do
        error = Exceptions::BadRequestError.new("Invalid request")
        allow_any_instance_of(SummarizeTextService).to receive(:call).and_raise(error)

        expect {
          described_class.call(valid_text)
        }.to raise_error(Exceptions::BadRequestError)
      end
    end
  end
end
