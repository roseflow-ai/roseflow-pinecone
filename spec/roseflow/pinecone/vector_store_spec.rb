# frozen_string_literal: true

require "spec_helper"

require "roseflow/pinecone/vector_store"

module Roseflow
  module Pinecone
    RSpec.describe VectorStore do
      it "inherits from Roseflow::VectorStores::Base" do
        expect(described_class.new).to be_kind_of Roseflow::VectorStores::Base
      end

      describe "VectorStore API" do
        let(:vector_store) { described_class.new }

        describe "#build_vector" do
          it { expect(vector_store).to respond_to(:build_vector) }

          it "returns a VectorObject" do
            expect(vector_store.build_vector("test", [1.0, 2.0, 3.0])).to be_a Roseflow::Pinecone::Vector::VectorObject
          end
        end

        describe "#create_vector" do
          it { expect(vector_store).to respond_to(:create_vector) }

          it "stores a vector" do
            VCR.use_cassette("pinecone/vector_store/create_vector", record: :new_episodes, allow_playback_repeats: true) do
              vector = vector_store.build_vector("xyz", [1.0, 2.0, 3.0])
              expect(vector_store.create_vector("roseflow-test", vector)).to be_truthy
            end
          end
        end

        describe "#delete_vector" do
          it { expect(vector_store).to respond_to(:delete_vector) }

          it "deletes a vector" do
            VCR.use_cassette("pinecone/vector_store/delete_vector", record: :new_episodes, allow_playback_repeats: true) do
              expect(vector_store.delete_vector("roseflow-test", "xyz")).to be_truthy
            end
          end
        end

        describe "#update_vector" do
          it { expect(vector_store).to respond_to(:update_vector) }

          it "updates a vector" do
            VCR.use_cassette("pinecone/vector_store/update_vector", record: :new_episodes, allow_playback_repeats: true) do
              expect(vector_store.update_vector("roseflow-test", id: "xyz", values: [4.0, 3.0, 2.0])).to be_truthy
            end
          end
        end

        describe "#query" do
          it { expect(vector_store).to respond_to(:query) }
          it { expect(vector_store).to respond_to(:where) }

          context "with a matching query" do
            it "returns an array of VectorObjects" do
              VCR.use_cassette("pinecone/vector_store/query_vector/matching", record: :new_episodes, allow_playback_repeats: true) do
                expect(vector_store.query("roseflow-test", id: "xyz")).to be_a Array
              end
            end

            it "returns an array of VectorObjects" do
              VCR.use_cassette("pinecone/vector_store/query_vector/matching/vectors", record: :new_episodes, allow_playback_repeats: true) do
                expect(vector_store.query("roseflow-test", vector: [100.0, 101.0, 102.0])).to all(be_a Vector::VectorObject)
              end
            end
          end

          context "with a non-matching query" do
            it "returns empty array" do
              VCR.use_cassette("pinecone/vector_store/query_vector/non_matching", record: :all, allow_playback_repeats: true) do
                expect(vector_store.query("roseflow-test", id: "abc")).to be_empty
              end
            end
          end
        end

        describe "#find" do
          it { expect(vector_store).to respond_to(:find) }

          it "finds a vector" do
            VCR.use_cassette("pinecone/vector_store/find_vector", record: :new_episodes, allow_playback_repeats: true) do
              expect(vector_store.find("roseflow-test", "xyz")).to be_a Roseflow::Pinecone::Vector::VectorObject
            end
          end
        end
      end
    end
  end
end