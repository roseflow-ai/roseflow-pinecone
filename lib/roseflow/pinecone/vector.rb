# frozen_string_literal: true

require "roseflow/pinecone/vectors/deletion"
require "roseflow/pinecone/vectors/query"
require "roseflow/pinecone/vectors/upsert"
require "roseflow/pinecone/vectors/update"
require "roseflow/pinecone/response"

module Roseflow
  module Pinecone
    class Vector
      attr_reader :connection

      def initialize(connection)
        @connection = connection
      end

      def self.build(id:, values:, sparse_values: nil, metadata: nil)
        VectorObject.new(
          id: id,
          values: values,
          sparse_values: sparse_values,
          metadata: metadata,
        )
      end

      def empty?(namespace = "")
        query(namespace: namespace).vectors.empty?
      end

      def query(query)
        object = query.is_a?(Query) ? query : Query.new(query)
        VectorQueryResponse.new(
          method: :query,
          response: @connection.post("/query", object.to_json),
        )
      end

      def delete(query)
        object = query.is_a?(Deletion) ? query : Deletion.new(query)
        VectorResponse.new(
          method: :delete,
          response: @connection.post("/vectors/delete", object.to_json),
        )
      end

      def update(vectors)
        object = vectors.is_a?(Update) ? vectors : Update.new(vectors)
        VectorResponse.new(
          method: :update,
          response: @connection.post("/vectors/update", object.to_json),
        )
      end

      def upsert(data)
        object = data.is_a?(Upsert) ? data : Upsert.from(data)
        VectorResponse.new(
          method: :upsert,
          response: @connection.post("/vectors/upsert", object.to_json),
        )
      end

      def fetch(options)
        query_string = URI.encode_www_form(
          {
            namespace: options.fetch(:namespace, ""),
            ids: options.fetch(:ids, []),
          }
        )
        VectorQueryResponse.new(
          method: :fetch,
          response: @connection.get("/vectors/fetch?#{query_string}"),
        )
      end
    end
  end
end
