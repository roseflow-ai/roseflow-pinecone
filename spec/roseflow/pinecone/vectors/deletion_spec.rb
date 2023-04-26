# frozen_string_literal: true

require "spec_helper"

require "roseflow/pinecone/vectors/deletion"

module Roseflow
  module Pinecone
    RSpec.describe Vector::Deletion do
      let(:command) { described_class.new(id: "foo") }

      it "can be initialized" do
        expect(command).to be_a described_class
      end

      context "with namespace" do
        let(:command) { described_class.new(id: "foo", namespace: "foo-space") }

        it "can be initialized" do
          expect(command).to be_a described_class
        end
      end

      context "with filter" do
        let(:filter) { Vector::Filter.new("$and": [{ genre: "drama" }, { genre: "comedy" }]) }
        let(:command) { described_class.new(id: "foo", filter: filter) }

        it "can be initialized" do
          expect(command).to be_a described_class
        end
      end

      context "delete all" do
        let(:filter) { Vector::Filter.new("$and": [{ genre: "drama" }, { genre: "comedy" }]) }
        let(:command) { described_class.new(filter: filter, delete_all: true) }

        it "can be initialized" do
          expect(command).to be_a described_class
        end
      end
    end
  end
end