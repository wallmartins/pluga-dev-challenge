require "rails_helper"
require "webmock/rspec"

RSpec.describe Gemini::HttpClient do
  let(:api_key) { "test-key" }
  let(:model) { "gemini-1.5-flash" }
  let(:client) { described_class.new(model: model, api_key: api_key) }

  describe "#post" do
    it "makes a POST request to the correct Gemini URL" do
      stub = stub_request(:post, %r{generativelanguage\.googleapis\.com/v1beta/models/#{model}:generateContent\?key=#{api_key}})
               .to_return(status: 200, body: "{}", headers: {})

      client.post({ test: "ok" })

      expect(stub).to have_been_requested
    end

    it "includes the correct headers" do
      stub = stub_request(:post, %r{generativelanguage\.googleapis\.com})
               .with(headers: { "Content-Type" => "application/json" })
               .to_return(status: 200, body: "{}")

      client.post({ something: true })
      expect(stub).to have_been_requested
    end

    it "returns a Net::HTTPResponse" do
      stub_request(:post, %r{generativelanguage\.googleapis\.com})
        .to_return(status: 200, body: "{}", headers: {})

      response = client.post({ test: "ok" })
      expect(response).to be_a(Net::HTTPResponse)
    end

    it "converts body to JSON" do
      stub = stub_request(:post, %r{generativelanguage\.googleapis\.com})
               .with(body: { contents: [{ parts: [{ text: "test" }] }] }.to_json)
               .to_return(status: 200, body: "{}")

      client.post({ contents: [{ parts: [{ text: "test" }] }] })

      expect(stub).to have_been_requested
    end

    it "uses SSL for secure connection" do
      stub = stub_request(:post, %r{https://generativelanguage\.googleapis\.com})
        .to_return(status: 200, body: "{}")

      client.post({ test: "ok" })

      expect(stub).to have_been_requested
    end

    it "includes model in URL" do
      stub = stub_request(:post, %r{generativelanguage\.googleapis\.com/v1beta/models/#{model}:generateContent})
               .to_return(status: 200, body: "{}")

      client.post({ test: "ok" })

      expect(stub).to have_been_requested
    end

    it "includes API key in URL as query parameter" do
      stub = stub_request(:post, %r{key=#{api_key}})
               .to_return(status: 200, body: "{}")

      client.post({ test: "ok" })

      expect(stub).to have_been_requested
    end

    it "handles empty body" do
      stub = stub_request(:post, %r{generativelanguage\.googleapis\.com})
               .to_return(status: 200, body: "{}")

      response = client.post({})
      expect(response).to be_a(Net::HTTPResponse)
    end

    it "returns error response from server" do
      stub = stub_request(:post, %r{generativelanguage\.googleapis\.com})
               .to_return(status: 500, body: { error: { message: "Server error" } }.to_json)

      response = client.post({ test: "ok" })
      expect(response.code).to eq("500")
    end
  end

  describe "#initialize" do
    it "stores model and api_key" do
      expect(client.instance_variable_get(:@model)).to eq(model)
      expect(client.instance_variable_get(:@api_key)).to eq(api_key)
    end
  end
end
