# frozen_string_literal: true

require "spec_helper"

require "roseflow/pinecone/vectors/upsert"

module Roseflow
  module Pinecone
    RSpec.describe Vector::Upsert do
      let(:vectors) {
        [
          Vector::VectorObject.new(id: "foo", values: [0.0, 0.5, -0.5]),
          Vector::VectorObject.new(id: "bar", values: [1.0, 0.5, -0.5])
        ]
      }
      let(:sparse_vector) { Vector::SparseVector.new(indices: [1,2,3], values: [1.2, 2.3, 3.4]) }

      context "with no optional attributes" do
        let(:command) { described_class.new(vectors: vectors) }

        it "can be initialized" do
          expect(command).to be_a(described_class)
        end
      end

      context "with sparse values" do
        let(:command) { described_class.new(vectors: vectors, sparse_values: sparse_vector) }

        it "can be initialized" do
          expect(command).to be_a(described_class)
        end
      end

      context "with metadata" do
        let(:command) { described_class.new(vectors: vectors, sparse_values: sparse_vector, metadata: { foo: "bar", bar: "baz" }) }

        it "can be initialized" do
          expect(command).to be_a(described_class)
        end
      end

      context "with namespace" do
        let(:command) { described_class.new(vectors: vectors, sparse_values: sparse_vector, metadata: { foo: "bar", bar: "baz" }, namespace: "foo-space") }

        it "can be initialized" do
          expect(command).to be_a(described_class)
        end  
      end
    end
  end
end