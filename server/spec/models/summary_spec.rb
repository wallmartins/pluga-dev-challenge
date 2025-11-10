require 'rails_helper'

RSpec.describe Summary, type: :model do
  describe "validations" do
    describe "original_post" do
      it "requires original_post to be present" do
        summary = build(:summary, original_post: nil)
        expect(summary).not_to be_valid
        expect(summary.errors[:original_post]).to include("can't be blank")
      end

      it "requires minimum 30 characters" do
        summary = build(:summary, original_post: "short")
        expect(summary).not_to be_valid
        expect(summary.errors[:original_post]).to include("is too short (minimum is 30 characters)")
      end

      it "accepts valid original_post" do
        summary = build(:summary, :with_text)
        expect(summary).to be_valid
      end
    end

    describe "status" do
      it "requires status to be present" do
        summary = build(:summary, status: nil)
        expect(summary).not_to be_valid
        expect(summary.errors[:status]).to include("is not included in the list")
      end

      it "only allows valid status values" do
        valid_statuses = ["pending", "completed", "failed"]
        valid_statuses.each do |status|
          summary = build(:summary, status: status)
          expect(summary).to be_valid
        end
      end
    end
  end

  describe "enums" do
    it "defines status enum with correct values" do
      expect(Summary.statuses.keys).to match_array(["pending", "completed", "failed"])
    end

    it "allows accessing status through enum methods" do
      summary = create(:summary, status: "pending")
      expect(summary.pending?).to be true
      expect(summary.completed?).to be false
      expect(summary.failed?).to be false
    end
  end

  describe "associations and attributes" do
    it { is_expected.to have_db_column(:original_post).of_type(:text) }
    it { is_expected.to have_db_column(:summary).of_type(:text) }
    it { is_expected.to have_db_column(:status).of_type(:string) }
  end

  describe "#save" do
    it "persists summary to database" do
      summary = create(:summary)
      persisted = Summary.find(summary.id)

      expect(persisted).to eq(summary)
    end

    it "updates existing summary" do
      summary = create(:summary, status: "pending")
      summary.update(status: "completed", summary: "Updated summary")

      reloaded = Summary.find(summary.id)
      expect(reloaded.status).to eq("completed")
      expect(reloaded.summary).to eq("Updated summary")
    end
  end

  describe "default values" do
    it "allows explicit status on creation" do
      summary = Summary.create!(original_post: "a" * 50, status: "completed", summary: "Test")
      expect(summary.status).to eq("completed")
    end
  end

  describe "nullability" do
    it "allows summary field to be null" do
      summary = create(:summary, summary: nil)
      expect(summary.summary).to be_nil
    end

    it "allows summary field to have value" do
      summary = create(:summary, :completed, summary: "A valid summary")
      expect(summary.summary).not_to be_nil
    end
  end

  describe "length validations edge cases" do
    it "rejects text with exactly 29 characters" do
      summary = build(:summary, original_post: "x" * 29)
      expect(summary).not_to be_valid
    end

    it "accepts text with exactly 30 characters" do
      summary = build(:summary, original_post: "x" * 30)
      expect(summary).to be_valid
    end

    it "accepts text longer than 30 characters" do
      summary = build(:summary, original_post: "x" * 100)
      expect(summary).to be_valid
    end

    it "accepts text with 1000+ characters" do
      summary = build(:summary, original_post: "x" * 1000)
      expect(summary).to be_valid
    end
  end

  describe "status enum behavior" do
    it "converts status to string when storing" do
      summary = create(:summary, status: "pending")
      expect(summary.status).to be_a(String)
    end

    it "queries by enum value" do
      create(:summary, status: "pending")
      create(:summary, status: "completed")

      pending_count = Summary.where(status: "pending").count
      expect(pending_count).to eq(1)
    end

    it "allows updating status" do
      summary = create(:summary, status: "pending")
      summary.update(status: "completed")

      expect(summary.status).to eq("completed")
    end
  end

  describe "timestamps" do
    it "has created_at timestamp" do
      summary = create(:summary)
      expect(summary.created_at).not_to be_nil
      expect(summary.created_at).to be_a(Time)
    end

    it "has updated_at timestamp" do
      summary = create(:summary)
      expect(summary.updated_at).not_to be_nil
      expect(summary.updated_at).to be_a(Time)
    end

    it "updates updated_at on modification" do
      summary = create(:summary)
      original_updated_at = summary.updated_at

      sleep(0.1)
      summary.update(status: "completed")

      expect(summary.updated_at).to be > original_updated_at
    end
  end

  describe "bulk operations" do
    it "creates multiple summaries" do
      summaries = create_list(:summary, 5, :completed)
      expect(Summary.count).to be >= 5
    end

    it "deletes summary" do
      summary = create(:summary)
      id = summary.id

      summary.destroy

      expect { Summary.find(id) }.to raise_error(ActiveRecord::RecordNotFound)
    end
  end

  describe "complex validations" do
    it "validates full error messages" do
      summary = build(:summary, original_post: "short")
      summary.validate

      expect(summary.errors[:original_post]).not_to be_empty
    end

    it "has specific error message for blank original_post" do
      summary = build(:summary, original_post: nil)
      expect(summary).not_to be_valid
      expect(summary.errors[:original_post]).to include("can't be blank")
    end
  end

  describe "status transitions" do
    it "transitions from pending to completed" do
      summary = create(:summary, status: "pending")
      summary.update(status: "completed")
      expect(summary.status).to eq("completed")
    end

    it "transitions from pending to failed" do
      summary = create(:summary, status: "pending")
      summary.update(status: "failed")
      expect(summary.status).to eq("failed")
    end

    it "transitions from any status to another" do
      summary = create(:summary, status: "completed")
      summary.update(status: "failed")
      expect(summary.status).to eq("failed")
    end
  end

  describe "special characters handling" do
    it "stores original_post with special characters" do
      special_text = "Text with special chars: !@#$%^&*() and symbols: <>'\" \\ /"
      summary = create(:summary, original_post: special_text * 2)
      expect(summary.original_post).to include("!@#$%^&*()")
    end

    it "stores summary with unicode characters" do
      unicode_summary = "Resumo em português: Olá, mundo! 你好世界"
      summary = create(:summary, :completed, summary: unicode_summary)
      expect(summary.summary).to eq(unicode_summary)
    end
  end
end
