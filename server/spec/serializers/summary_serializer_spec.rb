require 'rails_helper'

RSpec.describe SummarySerializer do
  let(:summary) { create(:summary, :completed, summary: Faker::Lorem.paragraph) }

  describe "#as_json" do
    context "without detailed flag" do
      it "returns hash with required fields" do
        serializer = described_class.new(summary, detailed: false)
        result = serializer.as_json

        expect(result).to be_a(Hash)
        expect(result.keys).to include(:id, :status, :summary, :created_at, :original_post)
      end

      it "includes summary ID" do
        serializer = described_class.new(summary)
        result = serializer.as_json

        expect(result[:id]).to eq(summary.id)
      end

      it "includes summary status" do
        serializer = described_class.new(summary)
        result = serializer.as_json

        expect(result[:status]).to eq(summary.status)
      end

      it "includes original post text" do
        serializer = described_class.new(summary)
        result = serializer.as_json

        expect(result[:original_post]).to eq(summary.original_post)
      end

      it "includes generated summary text" do
        serializer = described_class.new(summary)
        result = serializer.as_json

        expect(result[:summary]).to eq(summary.summary)
      end

      it "includes created_at timestamp" do
        serializer = described_class.new(summary)
        result = serializer.as_json

        expect(result[:created_at]).to eq(summary.created_at)
      end
    end

    context "with nil summary field" do
      it "includes nil summary when not yet generated" do
        pending_summary = create(:summary, status: "pending", summary: nil)
        serializer = described_class.new(pending_summary)
        result = serializer.as_json

        expect(result[:summary]).to be_nil
      end
    end

    context "with failed status" do
      it "serializes failed summary correctly" do
        failed_summary = create(:summary, :failed)
        serializer = described_class.new(failed_summary)
        result = serializer.as_json

        expect(result[:status]).to eq("failed")
        expect(result[:summary]).to be_nil
      end
    end

    context "with different statuses" do
      %w[pending completed failed].each do |status|
        it "handles #{status} status" do
          summary_with_status = create(:summary, status:)
          serializer = described_class.new(summary_with_status)
          result = serializer.as_json

          expect(result[:status]).to eq(status)
        end
      end
    end
  end

  describe "with multiple summaries" do
    it "serializes multiple summaries correctly" do
      summaries = create_list(:summary, 3, :completed)
      serialized = summaries.map { |s| described_class.new(s).as_json }

      expect(serialized.size).to eq(3)
      serialized.each do |data|
        expect(data).to include(:id, :status, :summary, :created_at, :original_post)
      end
    end
  end
end
