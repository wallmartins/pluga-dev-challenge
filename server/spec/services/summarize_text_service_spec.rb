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
        allow(GeminiClient).to receive(:summarize).with(text).and_return(expected_summary)

        service = described_class.new(text)
        result = service.call

        expect(result).to eq(expected_summary)
      end

      it "calls GeminiClient.summarize with correct text" do
        allow(GeminiClient).to receive(:summarize).and_return(expected_summary)

        described_class.new(text).call

        expect(GeminiClient).to have_received(:summarize).with(text).once
      end
    end

    context "when GeminiClient raises ApiError" do
      it "propagates the error" do
        error = Exceptions::BadRequestError.new("Invalid request")
        allow(GeminiClient).to receive(:summarize).and_raise(error)

        service = described_class.new(text)

        expect {
          service.call
        }.to raise_error(Exceptions::BadRequestError)
      end
    end

    context "when GeminiClient raises unexpected error" do
      it "wraps error in ExternalServiceError" do
        allow(GeminiClient).to receive(:summarize).and_raise(StandardError, "Network error")

        service = described_class.new(text)

        expect {
          service.call
        }.to raise_error(Exceptions::ExternalServiceError) do |error|
          expect(error.message).to include("Unexpected error during summarization")
          expect(error.details).to include("Network error")
        end
      end
    end

    context "with empty text" do
      it "passes empty text to GeminiClient" do
        allow(GeminiClient).to receive(:summarize).and_return("Summary")

        described_class.new("").call

        expect(GeminiClient).to have_received(:summarize).with("")
      end
    end

    context "with very long text" do
      it "handles long text correctly" do
        long_text = Faker::Lorem.paragraphs(number: 50).join("\n\n")
        allow(GeminiClient).to receive(:summarize).and_return(expected_summary)

        service = described_class.new(long_text)
        result = service.call

        expect(result).to eq(expected_summary)
        expect(GeminiClient).to have_received(:summarize).with(long_text)
      end
    end
  end
end
