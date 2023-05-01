# frozen_string_literal: true

require "spec_helper"

pinecone_config = Roseflow::Pinecone::Config.new

VCR.configure do |config|
  config.filter_sensitive_data("<PINECONE_KEY>") { pinecone_config.api_key }
  config.filter_sensitive_data("<PINECONE_ENVIRONMENT>") { pinecone_config.environment }
end

module Roseflow
  module Pinecone
    RSpec.describe Client do
      let(:config) { Roseflow::Pinecone::Config.new }
      let(:environment) { config.environment }
      let(:api_key) { config.api_key }
      let(:client) { described_class.new(config) }

      describe "Initialization" do
        it "can be instantiated" do
          expect(client).to be_instance_of(described_class)
        end
      end

      describe "Configuration" do
        describe "Region" do
          it "sets the region" do
            connection = client.send(:connection)
            expect(connection.url_prefix.to_s).to match(/#{environment}/)
          end
        end

        describe "Index" do
          it "sets an URL for index" do
            VCR.use_cassette("pinecone/index_url", record: :new_episodes, allow_playback_repeats: true) do
              expect(client.index_url).to be_nil
              expect(client.index("roseflow-test")).to be_a(Vector)
              expect(client.index_url).to be_a String
              expect(client.index_url).to match(/roseflow-test/)
            end
          end
        end
      end

      describe "Indices" do
        describe "listing" do
          it "lists the indices" do
            VCR.use_cassette("pinecone/list_indices", record: :new_episodes, allow_playback_repeats: true) do
              expect(client.indices).to be_instance_of(Array)
              expect(client.indices).to all(be_instance_of(String))
            end
          end
        end

        describe "deletion" do
          context "successful" do
            it "deletes an index" do
              VCR.use_cassette("pinecone/delete_index", record: :new_episodes, allow_playback_repeats: true) do
                response = client.delete_index("roseflow-test")
                expect(response).to be_success
                expect(response.status).to eq 202
              end
            end
          end

          context "index does not exist" do
            it "responds with a 404" do
              VCR.use_cassette("pinecone/delete_index/not_found", record: :new_episodes, allow_playback_repeats: true) do
                response = client.delete_index("roseflow-nonexisting")
                expect(response).not_to be_success
                expect(response.status).to eq 404
              end
            end
          end

          context "pending deletion" do
            it "responds with a 409", skip: "Figure how to test pending deletion." do
              VCR.use_cassette("pinecone/delete_index/pending_deletion", record: :all, allow_playback_repeats: true) do
                client.create_index("roseflow-pending-deletion")
                client.delete_index("roseflow-pending-deletion")
                response = client.delete_index("roseflow-pending-deletion")
                expect(response).not_to be_success
                expect(response.status).to eq 409
              end
            end
          end
        end

        describe "creation" do
          context "successful" do
            it "can create an index" do
              VCR.use_cassette("pinecone/create_index", record: :new_episodes, allow_playback_repeats: true) do
                response = client.create_index("roseflow-test", dimensions: 1024)
                expect(response).to be_success
                expect(response.status).to eq 201
              end
            end
          end

          context "index already exists" do
            it "responds with a 400" do
              VCR.use_cassette("pinecone/create_index/exists", record: :new_episodes, allow_playback_repeats: true) do
                response = client.create_index("roseflow-test", dimensions: 1024)
                expect(response).not_to be_success
                expect(response.status).to eq 409
              end
            end
          end

          context "index exceeds quota" do
            it "responds with a 400" do
              VCR.use_cassette("pinecone/create_index/exceeds_quota", record: :new_episodes, allow_playback_repeats: true) do
                response = client.create_index("roseflow-test", dimensions: 1024)
                expect(response).not_to be_success
                expect(response.status).to eq 400
              end
            end
          end
        end
      end
    end # Client
  end # Pinecone
end # Roseflow