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
end
