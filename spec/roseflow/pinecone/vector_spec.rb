# frozen_string_literal: true

require "spec_helper"
require "roseflow/pinecone/vector"

VCR.configure do |c|
  c.configure_rspec_metadata!
  c.filter_sensitive_data("<PINECONE_KEY>") { Roseflow::Pinecone::Config.new.api_key }
  c.filter_sensitive_data("<PINECONE_ENVIRONMENT>") { Roseflow::Pinecone::Config.new.environment }
end

def pinecone_index_connection(config = Roseflow::Pinecone::Config.new, index_name = "roseflow-test")
  connection = Faraday.new(
    url: "https://roseflow-test-1601616.svc.us-east4-gcp.pinecone.io",
    headers: {
      "accept": "application/json; charset=utf-8",
      "Content-Type": "application/json",
      "Api-Key": config.api_key
    }
  ) do |faraday|
    faraday.request :json
    faraday.adapter Faraday.default_adapter
  end
end

module Roseflow
  module Pinecone
    RSpec.describe Vector do
      let(:connection) { pinecone_index_connection }
      let(:index) { Vector.new(connection) }

      describe "Upsert" do
        let(:data) do
          {
            vectors: [
              { id: "foo", values: [1.0, 2.0, 3.0] },
              { id: "bar", values: [4.0, 5.0, 6.0] }
            ]
          }
        end

        describe "successful response" do
          let(:response) {
            VCR.use_cassette("pinecone/vectors/upsert", record: :new_episodes) do
              index.upsert(data)
            end
          }

          it "returns a response" do
            expect(response).to be_a_success
            expect(response).to be_a VectorResponse
            expect(response.status).to eq(200)
            expect(response.upsert_count).to eq 2
          end
        end
    
        context "unsuccessful response" do
          describe "no vectors provided" do
            let(:response) {
              VCR.use_cassette("pinecone/vectors/upsert/unsuccessful", record: :new_episodes) do
                index.upsert({ vectors: []})
              end
            }
  
            it "returns a response" do
              expect(response).to be_a_failure
              expect(response.status).to eq(400)
              expect(response.message).to match(/No vectors provided/)
            end
          end

          describe "vector dimensions do not match" do
            let(:data) do
              {
                vectors: [
                  { id: "foo", values: [1.0, 2.0, 3.0, 4.0] },
                  { id: "bar", values: [4.0, 5.0, 6.0, 7.0] }
                ]
              }
            end

            let(:response) {
              VCR.use_cassette("pinecone/vectors/upsert/dimensions", record: :new_episodes) do
                index.upsert(data)
              end
            }

            it "returns a response" do
              expect(response).to be_a_failure
              expect(response.status).to eq(400)
              expect(response.message).to match(/does not match the dimension of the index/)
            end
          end
        end
      end

      describe "Querying" do
        let(:data) { { 
          vectors: [
            { values: [1.0, 2.0, 3.0], id: "1" },
            { values: [0.0, 1.0, -1.0], id: "2" },
            { values: [1.0, -1.0, 0.0], id: "3" }
          ] 
        } }
        let(:query_vector) { [0.5, -0.5, 0.0] }

        describe "successful response" do
          before do
            VCR.use_cassette("pinecone/vectors/query", record: :new_episodes) do
              index.upsert(data)
            end
          end
    
          let(:response) {
            VCR.use_cassette("pinecone/vectors/query", record: :new_episodes) do
              index.query(vector: query_vector)
            end
          }
    
          let(:query_object) {
            Pinecone::Vector::Query.new(vector: query_vector)
          }
    
          let(:response_with_object) {
            VCR.use_cassette("pinecone/vectors/query/with_object", record: :new_episodes) do
              index.query(query_object)
            end
          }
    
          let(:valid_result) {
            {
              results: [],
              matches: [
                {id: "3", score: 1.00000012, values: []},
                {id: "bar", score: -0.0805823, values: []},
                {id: "foo", score: -0.188982248, values: []},
                {id: "1", score: -0.188982248, values: []},
                {id: "2", score: -0.50000006, values: []}
              ],
              namespace: ""
            }
          }
      
          it "returns a response" do
            expect(response).to be_a_success
            expect(response.body.keys).to match_array(valid_result.keys.map(&:to_s))
          end
    
          it "returns a response when queried with object" do
            expect(response_with_object).to be_a_success
            expect(response.body.keys).to match_array(valid_result.keys.map(&:to_s))
          end
        end
      end

      describe "Deleting" do
        describe "successful response" do
          let(:data) {
            { vectors: [ { values: [1.2, 2.3, 3.4], id: "5" } ] }
          }

          before do
            VCR.use_cassette("pinecone/vectors/delete", record: :new_episodes) do
              index.upsert(data)
            end
          end

          let(:response) { VCR.use_cassette("pinecone/vectors/delete", record: :new_episodes) { index.delete(ids: ["5"]) } }

          it "returns a response" do
            expect(response.status).to eq(200)
          end
        end
      end

      describe "Updating" do
        describe "Successful response" do
          let(:data) { { vectors: [ { values: [1.2, 2.3, 3.4], id: "5" } ] } }
          let(:updated_data) { { values: [2.2, 3.3, 4.4], id: "5" } }

          before do
            VCR.use_cassette("pinecone/vectors/update", record: :new_episodes) do
              index.upsert(data)
            end
          end

          let(:response) { VCR.use_cassette("pinecone/vectors/update", record: :new_episodes) { index.update(updated_data) } }

          it "returns a response" do
            expect(response).to be_a_success
            expect(response.status).to eq(200)
          end
        end
      end

      describe "Fetching" do
        describe "Successful response" do
          let(:response) { VCR.use_cassette("pinecone/vectors/fetch", record: :new_episodes) { index.fetch(ids: ["1"]) } }

          it "returns a response" do
            expect(response).to be_a_success
            expect(response.status).to eq(200)
            expect(response.vectors.keys).to include("1")
          end
        end
      end
    end
  end
end