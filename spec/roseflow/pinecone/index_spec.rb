# frozen_string_literal: true

require "spec_helper"

pinecone_config = Roseflow::Pinecone::Config.new

VCR.configure do |config|
  config.filter_sensitive_data("<PINECONE_KEY>") { pinecone_config.api_key }
  config.filter_sensitive_data("<PINECONE_ENVIRONMENT>") { pinecone_config.environment }
end

def pinecone_connection(config = Roseflow::Pinecone::Config.new)
  connection = Faraday.new(
    url: "https://controller.#{config.environment}.pinecone.io",
    headers: {
      "accept": "application/json; charset=utf-8",
      "Api-Key": config.api_key
    }
  ) do |faraday|
    faraday.request :json
    faraday.adapter Faraday.default_adapter
  end
end

module Roseflow
  module Pinecone
    RSpec.describe Index do
      describe "Initialization" do
        it "requires a connection" do
          expect { described_class.new }.to raise_error ArgumentError
        end

        it "can be instantiated" do
          expect(described_class.new(double)).to be_instance_of(described_class)
        end
      end

      describe "Listing indices" do
        let(:connection) { pinecone_connection }

        it "returns a list of indices" do
          VCR.use_cassette("pinecone/indices/list", record: :new_episodes) do
            response = described_class.new(connection).list
            expect(response).to be_a IndexResponse
            expect(response.body).to be_a Array
          end
        end
      end

      describe "Describing an index" do
        let(:connection) { pinecone_connection }

        context "when index exists" do
          it "describes a given index" do
            VCR.use_cassette("pinecone/indices/describe/existing", record: :new_episodes) do
              response = described_class.new(connection).describe("roseflow-describe")
              expect(response).to be_a IndexResponse
              expect(response.body).to be_a Hash
              expect(response.object).to be_a Roseflow::Pinecone::Index::Description
              expect(response.object.name).to eq "roseflow-describe"
              expect(response.object.status.ready).to eq true
            end
          end
        end

        context "when index does not exist" do
          it "returns a response with an error" do
            VCR.use_cassette("pinecone/indices/describe/nonexistent", record: :new_episodes) do
              response = described_class.new(connection).describe("nonexistent-index")
              expect(response).to be_a IndexResponse
              expect(response.status).to eq 404
              expect(response.object).to eq nil
            end
          end
        end
      end

      describe "Deleting an index" do
        let(:connection) { pinecone_connection }

        context "when index exists" do
          it "deletes an index" do
            VCR.use_cassette("pinecone/indices/delete/existing", record: :new_episodes) do
              response = described_class.new(connection).delete("roseflow-test")
              expect(response).to be_a IndexResponse
              expect(response.status).to eq 202
            end
          end
        end
      end
      
      describe "Creating an index" do
        let(:connection) { pinecone_connection }

        it "creates a new index" do
          VCR.use_cassette("pinecone/indices/create", record: :new_episodes) do
            response = described_class.new(connection).create("roseflow-test-create", {})
            expect(response).to be_a IndexResponse
            expect(response.status).to eq 201
          end
        end

        it "returns an error when creating an index that already exists" do
          VCR.use_cassette("pinecone/indices/create/over_quota", record: :new_episodes) do
            response = described_class.new(connection).create("roseflow-test", {})
            expect(response).to be_a IndexResponse
            expect(response.status).to eq 400
            expect(response.body).to match(/exceeds the project quota/)
          end
        end
      end
    end
  end
end