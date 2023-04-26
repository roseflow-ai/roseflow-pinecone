# frozen_string_literal: true

require "spec_helper"

require "roseflow/pinecone/vectors/update"

module Roseflow
  module Pinecone
    RSpec.describe Vector::Update do
      let(:vectors) { [0.0, 1.0, -1.0, 0.5, -0.5] }
      let(:sparse_vector) { Vector::SparseVector.new(indices: [1,2,3], values: [1.2, 2.3, 3.4]) }

      context "with no optional attributes" do
        let(:command) { described_class.new(id: "foo") }

        it "can be initialized" do
          expect(command).to be_a described_class
        end
      end

      context "with vectors" do
        let(:command) { described_class.new(id: "foo", vectors: vectors) }

        it "can be initialized" do
          expect(command).to be_a described_class
        end
      end

      context "with sparse values" do
        let(:command) { described_class.new(id: "foo", vectors: vectors, sparse_values: sparse_vector) }

        it "can be initialized" do
          expect(command).to be_a described_class
        end
      end

      context "with metadata" do
        let(:command) { described_class.new(id: "foo", vectors: vectors, sparse_values: sparse_vector, metadata: { foo: "bar", bar: "baz" }) }

        it "can be initialized" do
          expect(command).to be_a described_class
        end
      end

      context "with namespace" do
        let(:command) { described_class.new(id: "foo", vectors: vectors, sparse_values: sparse_vector, metadata: { foo: "bar", bar: "baz" }, namespace: "foo-space") }

        it "can be initialized" do
          expect(command).to be_a described_class
        end
      end
    end
  end
end