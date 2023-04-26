# frozen_string_literal: true

require "spec_helper"

require "roseflow/pinecone/vectors/vector_object"
require "roseflow/pinecone/vectors/sparse_vector"

module Roseflow
  module Pinecone
    RSpec.describe Vector::VectorObject do
      let(:vectors) { [0.0, 0.5, -0.5] }
      let(:object) { described_class.new(id: "foo", values: vectors) }

      it "can be initialized" do
        expect(object).to be_a(described_class)
      end

      context "Optional attributes" do
        context "with sparse values" do
          let(:sparse_values) { Vector::SparseVector.new(indices: [1,2,3], values: [1.2, 2.3, 3.4]) }
          let(:object) { described_class.new(id: "foo", values: vectors, sparse_values: sparse_values) }

          it "can be initialized" do
            expect(object).to be_a(described_class)
          end
        end

        context "with metadata" do
          let(:object) { described_class.new(id: "foo", values: vectors, metadata: {foo: "bar", bar: "baz"}) }

          it "can be initialized" do
            expect(object).to be_a(described_class)
          end
        end
      end
    end
  end
end