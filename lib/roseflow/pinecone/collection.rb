# frozen_string_literal: true

require "roseflow/pinecone/response"
require "roseflow/pinecone/structs"

module Roseflow
  module Pinecone
    class Collection
      def initialize(connection)
        @connection = connection
      end

      def list
        CollectionResponse.new(
          method: :list,
          response: connection.get("/collections")
        )
      end

      def describe(name)
        CollectionResponse.new(
          method: :describe,
          response: connection.get("/collections/#{name}")
        )
      end

      def create(name = "", source_index = "")
        CollectionResponse.new(
          method: :create,
          response: connection.post("/collections", { name: name, source: source_index })
        )
      end

      def delete(name)
        CollectionResponse.new(
          method: :delete,
          response: connection.delete("/collections/#{name}")
        )
      end

      private

      attr_reader :connection
    end
  end
end