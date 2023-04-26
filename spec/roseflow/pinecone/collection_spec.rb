# frozen_string_literal: true

require "spec_helper"

Anyway::Settings.use_local_files = true

pinecone_config = Roseflow::Pinecone::Config.new

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

VCR.configure do |config|
  config.filter_sensitive_data("<PINECONE_KEY>") { pinecone_config.api_key }
  config.filter_sensitive_data("<PINECONE_ENVIRONMENT>") { pinecone_config.environment }
end

module Roseflow
  module Pinecone
    RSpec.describe Collection do
      let(:config) { Roseflow::Pinecone::Config.new }
      let(:environment) { config.environment }
      let(:api_key) { config.api_key }
      
      describe "Initialization" do
        it "requires a connection" do
          expect { described_class.new }.to raise_error ArgumentError
        end

        it "can be instantiated" do
          expect(described_class.new(double)).to be_instance_of(described_class)
        end
      end

      describe "Listing collections" do
        let(:connection) { pinecone_connection(config) }

        it "returns a list of collections" do
          VCR.use_cassette("pinecone/collections/list", record: :all) do
            response = described_class.new(connection).list
            expect(response).to be_a CollectionResponse
            expect(response.body).to be_a Array
          end
        end
      end

      describe "Describing a collection" do
        let(:connection) { pinecone_connection(config) }

        before do
          VCR.use_cassette("pinecone/collections/create", record: :new_episodes) do
            described_class.new(connection).create("example-collection", "roseflow-test")
          end
        end
        
        context "when collection exists" do
          it "describes a given collection" do
            VCR.use_cassette("pinecone/collections/describe/existing", record: :new_episodes) do
              response = described_class.new(connection).describe("example-collection")
              expect(response).to be_a CollectionResponse
              expect(response.status).to eq 200
              expect(response.object).to be_a Roseflow::Pinecone::Collection::Description
            end
          end
        end
      end

      describe "Deleting a collection" do
        let(:connection) { pinecone_connection(config) }

        context "when collection exists" do
          it "deletes a given collection" do
            VCR.use_cassette("pinecone/collections/delete/existing", record: :new_episodes) do
              response = described_class.new(connection).delete("example-collection")
              expect(response).to be_a CollectionResponse
              expect(response.status).to eq 202
            end
          end
        end
      end

      describe "Creating a collection" do
        let(:connection) { pinecone_connection(config) }

        context "when collection does not exist" do
          it "creates a new collection" do
            VCR.use_cassette("pinecone/collections/create", record: :new_episodes) do
              response = described_class.new(connection).create("new-collection", "roseflow-test")
              expect(response).to be_a CollectionResponse
              expect(response.status).to eq 201
            end
          end
        end
      end
    end
  end
end