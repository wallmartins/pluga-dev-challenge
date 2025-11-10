# frozen_string_literal: true

require "rails_helper"
require "webmock/rspec"

RSpec.describe Gemini::Client, type: :request do
  let(:text) { "This is the input text to summarize." }
  let(:api_key) { "test-api-key" }
  let(:model) { "gemini-2.5-flash" }

  before do
    allow(ENV).to receive(:fetch).and_call_original
    allow(ENV).to receive(:fetch).with("GEMINI_KEY").and_return(api_key)
    allow(ENV).to receive(:fetch).with("GEMINI_MODEL", "gemini-2.5-flash").and_return(model)
  end

  describe ".summarize" do
    context "when all dependencies work correctly" do
      it "returns the summary successfully" do
        stub_request(:post, %r{generativelanguage\.googleapis\.com})
          .to_return(status: 200, body: { candidates: [ { content: { parts: [ { text: "AI summary" } ] } } ] }.to_json)

        result = described_class.summarize(text)
        expect(result).to eq("AI summary")
      end
    end

    context "when InputSanitizer raises an error" do
      it "wraps the error as ExternalServiceError" do
        allow(InputSanitizer).to receive(:clean).and_raise(StandardError, "sanitizer failed")

        expect {
          described_class.summarize(text)
        }.to raise_error(ExternalServiceError)
      end
    end

    context "when ResponseHandler raises a known ApiError" do
      it "propagates the ApiError" do
        allow(InputSanitizer).to receive(:clean).and_return(text)
        allow(Gemini::RequestBuilder).to receive(:new).and_return(double(build!: {}))
        allow(Gemini::HttpClient).to receive(:new).and_return(double(post: "dummy_response"))
        allow(Gemini::ResponseHandler).to receive(:new).and_raise(ApiError.new("Gemini API down"))

        expect {
          described_class.summarize(text)
        }.to raise_error(ApiError)
      end
    end

    context "with real HTTP call (integration test with WebMock)" do
      it "returns parsed summary when response is successful" do
        expected_summary = "This is the AI summary."
        stub_request(:post, %r{generativelanguage\.googleapis\.com})
          .to_return(
            status: 200,
            body: {
              candidates: [
                { content: { parts: [ { text: expected_summary } ] } }
              ]
            }.to_json,
            headers: { "Content-Type" => "application/json" }
          )

        result = described_class.summarize(text)
        expect(result).to eq(expected_summary)
      end

      it "raises ExternalServiceError on 500 response" do
        stub_request(:post, %r{generativelanguage\.googleapis\.com})
          .to_return(status: 500, body: { error: { message: "Internal error" } }.to_json)

        expect {
          described_class.summarize(text)
        }.to raise_error(ExternalServiceError)
      end
    end
  end
end
