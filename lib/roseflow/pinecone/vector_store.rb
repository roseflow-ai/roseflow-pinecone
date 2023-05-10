# frozen_string_literal: true

require "roseflow/vector_stores/base"
require "roseflow/pinecone"
require "roseflow/pinecone/vector"
require "roseflow/pinecone/vectors/vector_object"

module Roseflow
  module Pinecone
    class VectorStore < Roseflow::VectorStores::Base
      attr_reader :client

      def initialize
        @client = Roseflow::Pinecone::Client.new
      end

      def index(name)
        client.index(name)
      end

      def build_vector(name, content)
        Vector.build(id: name, values: content)
      end

      def create_vector(name, vector, **options)
        index(name).upsert(options.merge(vectors: [vector]))
      end

      def delete_vector(name, id)
        index(name).delete(ids: [id])
      end

      def update_vector(name, vector)
        index(name).update(vector)
      end

      def query(name, query)
        index(name).query(query).vectors
      end

      alias_method :where, :query

      def find(name, ids, **options)
        index(name).fetch(options.merge(ids: ids)).vectors.first
      end
    end
  end
end