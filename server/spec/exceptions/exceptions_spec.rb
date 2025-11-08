require 'rails_helper'

RSpec.describe Exceptions do
  it "is a module" do
    expect(described_class).to be_a(Module)
  end

  it "contains ApiError class" do
    expect(described_class::ApiError).to be_a(Class)
  end

  it "contains BadRequestError class" do
    expect(described_class::BadRequestError).to be_a(Class)
  end

  it "contains NotFoundError class" do
    expect(described_class::NotFoundError).to be_a(Class)
  end

  it "contains ValidationError class" do
    expect(described_class::ValidationError).to be_a(Class)
  end

  it "contains InternalServerError class" do
    expect(described_class::InternalServerError).to be_a(Class)
  end

  it "contains ExternalServiceError class" do
    expect(described_class::ExternalServiceError).to be_a(Class)
  end
end
