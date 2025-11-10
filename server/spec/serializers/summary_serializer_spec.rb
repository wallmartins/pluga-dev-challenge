# frozen_string_literal: true

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

  describe "with detailed flag" do
    it "serializes with detailed flag set to true" do
      serializer = described_class.new(summary, detailed: true)
      result = serializer.as_json

      expect(result).to include(:id, :status, :summary, :created_at, :original_post)
    end

    it "preserves all fields with detailed flag" do
      serializer = described_class.new(summary, detailed: true)
      result = serializer.as_json

      expect(result[:id]).to eq(summary.id)
      expect(result[:status]).to eq(summary.status)
      expect(result[:summary]).to eq(summary.summary)
      expect(result[:original_post]).to eq(summary.original_post)
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

  describe "#initialization" do
    it "stores summary instance" do
      serializer = described_class.new(summary, detailed: false)
      expect(serializer.instance_variable_get(:@summary)).to eq(summary)
    end

    it "stores detailed flag when provided" do
      serializer = described_class.new(summary, detailed: true)
      expect(serializer.instance_variable_get(:@detailed)).to be true
    end

    it "defaults detailed flag to false when not provided" do
      serializer = described_class.new(summary)
      expect(serializer.instance_variable_get(:@detailed)).to be false
    end
  end

  describe "type conversion" do
    it "returns hash from as_json" do
      serializer = described_class.new(summary)
      result = serializer.as_json

      expect(result).to be_a(Hash)
    end

    it "includes timestamps as correct format" do
      serializer = described_class.new(summary)
      result = serializer.as_json

      expect(result[:created_at]).to eq(summary.created_at)
    end
  end

  describe "with pending status" do
    it "serializes pending summary correctly" do
      pending = create(:summary, status: "pending", summary: nil)
      serializer = described_class.new(pending)
      result = serializer.as_json

      expect(result[:status]).to eq("pending")
      expect(result[:summary]).to be_nil
      expect(result[:original_post]).to eq(pending.original_post)
    end
  end

  describe "edge cases" do
    it "handles summary with empty string text" do
      summary_with_empty = create(:summary, :completed, summary: "")
      serializer = described_class.new(summary_with_empty)
      result = serializer.as_json

      expect(result[:summary]).to eq("")
    end

    it "handles very long summary text" do
      long_text = "a" * 5000
      summary_with_long = create(:summary, :completed, summary: long_text)
      serializer = described_class.new(summary_with_long)
      result = serializer.as_json

      expect(result[:summary]).to eq(long_text)
      expect(result[:summary].length).to eq(5000)
    end

    it "handles special characters in summary" do
      summary_special = create(:summary, :completed, summary: "Special chars: !@#$%^&*()")
      serializer = described_class.new(summary_special)
      result = serializer.as_json

      expect(result[:summary]).to eq("Special chars: !@#$%^&*()")
    end

    it "handles unicode characters in summary" do
      unicode_summary = create(:summary, :completed, summary: "Resumo em português: Olá, mundo!")
      serializer = described_class.new(unicode_summary)
      result = serializer.as_json

      expect(result[:summary]).to eq("Resumo em português: Olá, mundo!")
    end

    it "handles unicode in original_post" do
      unicode_post = create(:summary, original_post: "Conteúdo original com acentuação: São Paulo, Brasil.")
      serializer = described_class.new(unicode_post)
      result = serializer.as_json

      expect(result[:original_post]).to eq(unicode_post.original_post)
    end
  end

  describe "consistency across calls" do
    it "returns same data on multiple calls" do
      serializer = described_class.new(summary)
      first_call = serializer.as_json
      second_call = serializer.as_json

      expect(first_call).to eq(second_call)
    end

    it "returns different serializers for different summaries" do
      summary1 = create(:summary, :completed)
      summary2 = create(:summary, :completed)

      result1 = described_class.new(summary1).as_json
      result2 = described_class.new(summary2).as_json

      expect(result1[:id]).not_to eq(result2[:id])
    end
  end
end
