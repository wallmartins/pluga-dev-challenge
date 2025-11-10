# frozen_string_literal: true

require 'rails_helper'

RSpec.describe SummarizeSummaryJob do
  let(:text) { Faker::Lorem.paragraph(sentence_count: 10) }
  let(:summary_text) { Faker::Lorem.paragraph(sentence_count: 2) }
  let(:summary) { create(:summary, original_post: text) }

  describe "#perform" do
    context "when summary generation succeeds" do
      it "calls GenerateSummaries with original post" do
        allow(GenerateSummaries).to receive(:call).and_return(summary_text)

        described_class.new.perform(summary.id)

        expect(GenerateSummaries).to have_received(:call).with(text)
      end

      it "persists summary to database" do
        allow(GenerateSummaries).to receive(:call).and_return(summary_text)

        described_class.new.perform(summary.id)

        summary.reload
        expect(summary.summary).to eq(summary_text)
        expect(summary.status).to eq("completed")
      end
    end

    context "when GenerateSummaries raises ValidationError" do
      it "updates summary status to failed with validation error message" do
        error = Exceptions::ValidationError.new(entity: "Summary", message: "Invalid content")
        allow(GenerateSummaries).to receive(:call).and_raise(error)

        expect {
          described_class.new.perform(summary.id)
        }.to raise_error(Exceptions::ValidationError)

        summary.reload
        expect(summary.status).to eq("failed")
        expect(summary.summary).to eq("Invalid content")
      end

      it "logs validation error" do
        error = Exceptions::ValidationError.new(entity: "Summary", message: "Invalid content")
        allow(GenerateSummaries).to receive(:call).and_raise(error)
        allow(Rails.logger).to receive(:error)

        expect {
          described_class.new.perform(summary.id)
        }.to raise_error(Exceptions::ValidationError)

        expect(Rails.logger).to have_received(:error).with(
          /Validation error while summarizing ID=#{summary.id}/
        )
      end
    end

    context "when GenerateSummaries raises BadRequestError" do
      it "updates summary status to failed with user-friendly message" do
        error = Exceptions::BadRequestError.new("Invalid request")
        allow(GenerateSummaries).to receive(:call).and_raise(error)

        expect {
          described_class.new.perform(summary.id)
        }.to raise_error(Exceptions::BadRequestError)

        summary.reload
        expect(summary.status).to eq("failed")
        expect(summary.summary).to include("padrões suspeitos")
      end

      it "logs bad request error" do
        error = Exceptions::BadRequestError.new("Invalid request")
        allow(GenerateSummaries).to receive(:call).and_raise(error)
        allow(Rails.logger).to receive(:error)

        expect {
          described_class.new.perform(summary.id)
        }.to raise_error(Exceptions::BadRequestError)

        expect(Rails.logger).to have_received(:error).with(
          /Bad request while summarizing ID=#{summary.id}/
        )
      end

      it "re-raises the error" do
        error = Exceptions::BadRequestError.new("Invalid request")
        allow(GenerateSummaries).to receive(:call).and_raise(error)

        expect {
          described_class.new.perform(summary.id)
        }.to raise_error(Exceptions::BadRequestError, /Invalid request/)
      end
    end

    context "when GenerateSummaries raises ExternalServiceError" do
      it "updates summary status to failed with service unavailable message" do
        error = Exceptions::ExternalServiceError.new(service_name: "Gemini API")
        allow(GenerateSummaries).to receive(:call).and_raise(error)

        expect {
          described_class.new.perform(summary.id)
        }.to raise_error(Exceptions::ExternalServiceError)

        summary.reload
        expect(summary.status).to eq("failed")
        expect(summary.summary).to include("temporariamente indisponível")
      end

      it "logs external service error" do
        error = Exceptions::ExternalServiceError.new(service_name: "Gemini API")
        allow(GenerateSummaries).to receive(:call).and_raise(error)
        allow(Rails.logger).to receive(:error)

        expect {
          described_class.new.perform(summary.id)
        }.to raise_error(Exceptions::ExternalServiceError)

        expect(Rails.logger).to have_received(:error).with(
          /External service error while summarizing ID=#{summary.id}/
        )
      end

      it "re-raises the error" do
        error = Exceptions::ExternalServiceError.new(service_name: "Gemini API")
        allow(GenerateSummaries).to receive(:call).and_raise(error)

        expect {
          described_class.new.perform(summary.id)
        }.to raise_error(Exceptions::ExternalServiceError)
      end
    end

    context "when GenerateSummaries raises generic ApiError" do
      it "updates summary status to failed with api error message" do
        error = Exceptions::ApiError.new("Generic API error")
        allow(GenerateSummaries).to receive(:call).and_raise(error)

        expect {
          described_class.new.perform(summary.id)
        }.to raise_error(Exceptions::ApiError)

        summary.reload
        expect(summary.status).to eq("failed")
        expect(summary.summary).to eq("Generic API error")
      end

      it "logs api error" do
        error = Exceptions::ApiError.new("Generic API error")
        allow(GenerateSummaries).to receive(:call).and_raise(error)
        allow(Rails.logger).to receive(:error)

        expect {
          described_class.new.perform(summary.id)
        }.to raise_error(Exceptions::ApiError)

        expect(Rails.logger).to have_received(:error).with(
          /API error while summarizing ID=#{summary.id}/
        )
      end

      it "re-raises the error" do
        error = Exceptions::ApiError.new("Generic API error")
        allow(GenerateSummaries).to receive(:call).and_raise(error)

        expect {
          described_class.new.perform(summary.id)
        }.to raise_error(Exceptions::ApiError, /Generic API error/)
      end
    end

    context "when unexpected error occurs" do
      it "updates summary status to failed" do
        allow(GenerateSummaries).to receive(:call).and_raise(StandardError, "Network error")

        expect {
          described_class.new.perform(summary.id)
        }.to raise_error(Exceptions::InternalServerError)

        summary.reload
        expect(summary.status).to eq("failed")
      end

      it "logs the unexpected error" do
        error = StandardError.new("Connection timeout")
        allow(GenerateSummaries).to receive(:call).and_raise(error)
        allow(Rails.logger).to receive(:error)

        expect {
          described_class.new.perform(summary.id)
        }.to raise_error(Exceptions::InternalServerError)

        expect(Rails.logger).to have_received(:error).with(
          /Unexpected error in SummarizeSummaryJob ID=#{summary.id}/
        )
      end

      it "wraps error in InternalServerError" do
        allow(GenerateSummaries).to receive(:call).and_raise(StandardError, "Unknown error")

        expect {
          described_class.new.perform(summary.id)
        }.to raise_error(Exceptions::InternalServerError) do |error|
          expect(error.message).to include("Falha ao processar resumo")
          expect(error.status).to eq(500)
        end
      end

      it "saves user-friendly error message to summary" do
        allow(GenerateSummaries).to receive(:call).and_raise(StandardError, "Unknown error")

        expect {
          described_class.new.perform(summary.id)
        }.to raise_error(Exceptions::InternalServerError)

        summary.reload
        expect(summary.summary).to include("erro inesperado")
      end
    end

    context "when summary record is not found" do
      it "wraps RecordNotFound as InternalServerError" do
        non_existent_id = 99999
        allow(Rails.logger).to receive(:error)

        expect {
          described_class.new.perform(non_existent_id)
        }.to raise_error(Exceptions::InternalServerError) do |error|
          expect(error.message).to include("Falha ao processar resumo")
          expect(error.status).to eq(500)
        end

        expect(Rails.logger).to have_received(:error).with(
          /Unexpected error in SummarizeSummaryJob ID=#{non_existent_id}/
        )
      end

      it "does not try to update when summary is nil" do
        non_existent_id = 99999

        expect {
          described_class.new.perform(non_existent_id)
        }.to raise_error(Exceptions::InternalServerError)
      end
    end

    context "job configuration" do
      it "uses default queue" do
        expect(described_class.new.class.queue_name).to eq("default")
      end
    end
  end
end
