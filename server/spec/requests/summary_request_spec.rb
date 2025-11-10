require 'rails_helper'

RSpec.describe SummariesController do
  describe "#index" do
    it "calls Summary.order with created_at descending" do
      controller = described_class.new
      allow(Summary).to receive(:order).with(created_at: :desc).and_return([])
      allow(controller).to receive(:render)

      controller.send(:index)

      expect(Summary).to have_received(:order).with(created_at: :desc)
    end

    it "serializes each summary with SummarySerializer" do
      controller = described_class.new
      summary = create(:summary, original_post: "a" * 50)
      allow(Summary).to receive(:order).with(created_at: :desc).and_return([summary])

      expect(SummarySerializer).to receive(:new).with(summary).and_call_original
      allow(controller).to receive(:render)

      controller.send(:index)
    end

    it "renders json with array of serialized summaries" do
      controller = described_class.new
      initial_count = Summary.count
      create_list(:summary, 2, original_post: "a" * 50)

      expect(controller).to receive(:render) do |args|
        expect(args[:json]).to be_a(Array)
        expect(args[:json].length).to eq(initial_count + 2)
      end

      controller.send(:index)
    end
  end

  describe "#show" do
    it "finds summary by id parameter" do
      controller = described_class.new
      summary = create(:summary, original_post: "a" * 50)
      allow(controller).to receive(:params).and_return(ActionController::Parameters.new(id: summary.id))
      allow(controller).to receive(:render)

      expect(Summary).to receive(:find).with(summary.id).and_call_original

      controller.send(:show)
    end

    it "serializes summary with detailed flag" do
      controller = described_class.new
      summary = create(:summary, original_post: "a" * 50)
      allow(controller).to receive(:params).and_return(ActionController::Parameters.new(id: summary.id))

      expect(SummarySerializer).to receive(:new).with(summary, detailed: true).and_call_original
      allow(controller).to receive(:render)

      controller.send(:show)
    end

    it "renders json with serialized summary" do
      controller = described_class.new
      summary = create(:summary, original_post: "a" * 50)
      allow(controller).to receive(:params).and_return(ActionController::Parameters.new(id: summary.id))

      expect(controller).to receive(:render) do |args|
        expect(args[:json]).to be_a(Hash)
        expect(args[:json][:id]).to eq(summary.id)
      end

      controller.send(:show)
    end

    it "raises RecordNotFound for non-existent id" do
      controller = described_class.new
      allow(controller).to receive(:params).and_return(ActionController::Parameters.new(id: 99999))

      expect {
        controller.send(:show)
      }.to raise_error(ActiveRecord::RecordNotFound)
    end
  end

  describe "#create" do
    context "when summary is valid" do
      it "creates summary with pending status" do
        controller = described_class.new
        allow(controller).to receive(:params).and_return(
          ActionController::Parameters.new(summary: { original_post: "a" * 50 })
        )
        allow(controller).to receive(:render)

        expect(Summary).to receive(:new).with(
          hash_including(original_post: "a" * 50, status: "pending")
        ).and_call_original

        controller.send(:create)
      end

      it "enqueues SummarizeSummaryJob with summary id" do
        controller = described_class.new
        allow(controller).to receive(:params).and_return(
          ActionController::Parameters.new(summary: { original_post: "a" * 50 })
        )
        allow(controller).to receive(:render)

        expect(SummarizeSummaryJob).to receive(:perform_later).with(kind_of(Integer))

        controller.send(:create)
      end

      it "renders created status" do
        controller = described_class.new
        allow(controller).to receive(:params).and_return(
          ActionController::Parameters.new(summary: { original_post: "a" * 50 })
        )

        expect(controller).to receive(:render) do |args|
          expect(args[:status]).to eq(:created)
          expect(args[:json]).to be_a(Hash)
        end

        controller.send(:create)
      end
    end

    context "when summary is invalid" do
      it "raises ValidationError when original_post is too short" do
        controller = described_class.new
        allow(controller).to receive(:params).and_return(
          ActionController::Parameters.new(summary: { original_post: "short" })
        )

        expect {
          controller.send(:create)
        }.to raise_error(Exceptions::ValidationError) do |error|
          expect(error.message).to match(/at least 30 characters/)
        end
      end

      it "includes validation details in error" do
        controller = described_class.new
        allow(controller).to receive(:params).and_return(
          ActionController::Parameters.new(summary: { original_post: "short" })
        )

        expect {
          controller.send(:create)
        }.to raise_error(Exceptions::ValidationError) do |error|
          expect(error.details).to have_key(:original_post)
        end
      end
    end
  end

  describe "#summary_params" do
    it "requires summary parameter" do
      controller = described_class.new
      allow(controller).to receive(:params).and_return(
        ActionController::Parameters.new({})
      )

      expect {
        controller.send(:summary_params)
      }.to raise_error(ActionController::ParameterMissing)
    end

    it "permits only original_post parameter" do
      controller = described_class.new
      allow(controller).to receive(:params).and_return(
        ActionController::Parameters.new(
          summary: { original_post: "text", extra_field: "should be filtered" }
        )
      )

      params = controller.send(:summary_params)

      expect(params.to_h.keys).to eq(["original_post"])
    end

    it "returns ActionController::Parameters" do
      controller = described_class.new
      allow(controller).to receive(:params).and_return(
        ActionController::Parameters.new(
          summary: { original_post: "text" }
        )
      )

      params = controller.send(:summary_params)

      expect(params).to be_a(ActionController::Parameters)
    end
  end
end
