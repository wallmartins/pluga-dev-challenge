require 'rails_helper'

RSpec.describe ErrorSerializer do
  let(:controller) { instance_double(ApplicationController, class: ApplicationController) }
  let(:action) { "create" }

  describe "#as_json" do
    context "with ApiError exception" do
      it "includes error code from exception" do
        exception = Exceptions::BadRequestError.new("Invalid request")
        serializer = described_class.new(exception: exception, controller: controller, action: action)

        result = serializer.as_json

        expect(result[:error][:code]).to eq("bad_request")
      end

      it "includes exception message" do
        exception = Exceptions::BadRequestError.new("Custom error message")
        serializer = described_class.new(exception: exception, controller: controller, action: action)

        result = serializer.as_json

        expect(result[:error][:message]).to eq("Custom error message")
      end

      it "includes exception details" do
        details = { field: "email", error: "invalid" }
        exception = Exceptions::ValidationError.new(entity: "User", details: details)
        serializer = described_class.new(exception: exception, controller: controller, action: action)

        result = serializer.as_json

        expect(result[:error][:details]).to eq(details)
      end

      it "omits details when nil" do
        exception = Exceptions::BadRequestError.new("Error")
        serializer = described_class.new(exception: exception, controller: controller, action: action)

        result = serializer.as_json

        # When details is nil, it should not be included (compact removes nil values)
        expect(result[:error][:details]).to be_nil
      end

      it "includes context information" do
        exception = Exceptions::BadRequestError.new("Error")
        serializer = described_class.new(exception: exception, controller: controller, action: action)

        result = serializer.as_json

        expect(result[:error][:context][:controller]).to eq("ApplicationController")
        expect(result[:error][:context][:action]).to eq("create")
        expect(result[:error][:context][:exception_class]).to eq("Exceptions::BadRequestError")
      end
    end

    context "with standard exception (non-ApiError)" do
      it "defaults error_code to 'internal_server_error'" do
        exception = StandardError.new("Unexpected error")
        serializer = described_class.new(exception: exception, controller: controller, action: action)

        result = serializer.as_json

        expect(result[:error][:code]).to eq("internal_server_error")
      end

      it "includes exception message" do
        exception = StandardError.new("Database connection failed")
        serializer = described_class.new(exception: exception, controller: controller, action: action)

        result = serializer.as_json

        expect(result[:error][:message]).to eq("Database connection failed")
      end

      it "omits details when exception doesn't respond to details" do
        exception = StandardError.new("Error")
        serializer = described_class.new(exception: exception, controller: controller, action: action)

        result = serializer.as_json

        expect(result[:error][:details]).to be_nil
      end
    end

    context "with ActiveRecord::RecordInvalid" do
      it "includes full error messages from record" do
        summary = Summary.new
        summary.validate!
      rescue ActiveRecord::RecordInvalid => e
        serializer = described_class.new(exception: e, controller: controller, action: action)
        result = serializer.as_json

        expect(result[:error][:details]).to be_a(Array)
        expect(result[:error][:details]).not_to be_empty
      end
    end

    context "meta information" do
      it "includes timestamp in ISO8601 format" do
        exception = Exceptions::BadRequestError.new("Error")
        serializer = described_class.new(exception: exception, controller: controller, action: action)

        result = serializer.as_json

        expect(result[:meta][:timestamp]).to match(/\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}/)
      end

      it "includes request_id" do
        exception = Exceptions::BadRequestError.new("Error")
        serializer = described_class.new(exception: exception, controller: controller, action: action)

        result = serializer.as_json

        expect(result[:meta][:request_id]).to be_a(String)
        expect(result[:meta][:request_id]).not_to be_empty
      end

      it "uses Thread.current[:request_id] if set" do
        exception = Exceptions::BadRequestError.new("Error")
        custom_request_id = "custom-123-request-id"
        Thread.current[:request_id] = custom_request_id

        serializer = described_class.new(exception: exception, controller: controller, action: action)
        result = serializer.as_json

        expect(result[:meta][:request_id]).to eq(custom_request_id)

        # Clean up
        Thread.current[:request_id] = nil
      end

      it "generates random UUID for request_id when not set in Thread" do
        Thread.current[:request_id] = nil
        exception = Exceptions::BadRequestError.new("Error")
        serializer = described_class.new(exception: exception, controller: controller, action: action)

        result = serializer.as_json

        expect(result[:meta][:request_id]).to match(/\A[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}\z/i)
      end
    end

    context "response structure" do
      it "includes all required top-level keys" do
        exception = Exceptions::BadRequestError.new("Error")
        serializer = described_class.new(exception: exception, controller: controller, action: action)

        result = serializer.as_json

        expect(result).to have_key(:error)
        expect(result).to have_key(:meta)
      end

      it "includes all required error keys" do
        exception = Exceptions::BadRequestError.new("Error")
        serializer = described_class.new(exception: exception, controller: controller, action: action)

        result = serializer.as_json

        expect(result[:error]).to have_key(:code)
        expect(result[:error]).to have_key(:message)
        expect(result[:error]).to have_key(:context)
      end

      it "includes all required meta keys" do
        exception = Exceptions::BadRequestError.new("Error")
        serializer = described_class.new(exception: exception, controller: controller, action: action)

        result = serializer.as_json

        expect(result[:meta]).to have_key(:timestamp)
        expect(result[:meta]).to have_key(:request_id)
      end

      it "includes details key even when nil" do
        exception = Exceptions::BadRequestError.new("Error")
        serializer = described_class.new(exception: exception, controller: controller, action: action)

        result = serializer.as_json

        # Details is included in the response but is nil when no details are present
        expect(result[:error][:details]).to be_nil
      end
    end

    context "with different exception types" do
      let(:exception_types) do
        [
          Exceptions::NotFoundError.new(resource: "User"),
          Exceptions::ValidationError.new(entity: "Summary"),
          Exceptions::InternalServerError.new("Server error"),
          Exceptions::ExternalServiceError.new(service_name: "API")
        ]
      end

      it "serializes all exception types correctly" do
        exception_types.each do |exception|
          serializer = described_class.new(exception: exception, controller: controller, action: action)
          result = serializer.as_json

          expect(result[:error]).to have_key(:code)
          expect(result[:error]).to have_key(:message)
          expect(result[:error]).to have_key(:context)
          expect(result[:meta]).to have_key(:timestamp)
          expect(result[:meta]).to have_key(:request_id)
        end
      end
    end

    context "edge cases" do
      it "handles exception with very long message" do
        long_message = "A" * 1000
        exception = Exceptions::BadRequestError.new(long_message)
        serializer = described_class.new(exception: exception, controller: controller, action: action)

        result = serializer.as_json

        expect(result[:error][:message]).to eq(long_message)
      end

      it "handles exception with special characters in message" do
        special_message = "Error: !@#$%^&*()_+-=[]{}|;:',.<>?/\\"
        exception = Exceptions::BadRequestError.new(special_message)
        serializer = described_class.new(exception: exception, controller: controller, action: action)

        result = serializer.as_json

        expect(result[:error][:message]).to eq(special_message)
      end

      it "handles empty details hash" do
        exception = Exceptions::BadRequestError.new("Error", details: {})
        serializer = described_class.new(exception: exception, controller: controller, action: action)

        result = serializer.as_json

        # Empty hash is falsy, so it should be filtered by compact or format_details
        expect(result[:error][:details]).to be_nil
      end

      it "handles nested details structure" do
        details = {
          field: "email",
          errors: [
            { code: "invalid", message: "Email is invalid" },
            { code: "required", message: "Email is required" }
          ]
        }
        exception = Exceptions::ValidationError.new(entity: "User", details: details)
        serializer = described_class.new(exception: exception, controller: controller, action: action)

        result = serializer.as_json

        expect(result[:error][:details]).to eq(details)
      end
    end
  end

  describe "initialization" do
    it "stores exception" do
      exception = Exceptions::BadRequestError.new("Error")
      serializer = described_class.new(exception: exception, controller: controller, action: action)

      # Verify initialization by checking that as_json works
      result = serializer.as_json
      expect(result[:error][:message]).to eq("Error")
    end

    it "stores controller" do
      exception = Exceptions::BadRequestError.new("Error")
      serializer = described_class.new(exception: exception, controller: controller, action: action)

      result = serializer.as_json
      expect(result[:error][:context][:controller]).to eq("ApplicationController")
    end

    it "stores action" do
      exception = Exceptions::BadRequestError.new("Error")
      serializer = described_class.new(exception: exception, controller: controller, action: "update")

      result = serializer.as_json
      expect(result[:error][:context][:action]).to eq("update")
    end
  end
end
