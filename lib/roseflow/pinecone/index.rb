# frozen_string_literal: true

require "roseflow/pinecone/response"
require "roseflow/pinecone/structs"

module Roseflow
  module Pinecone
    class Index
      def initialize(connection)
        @connection = connection
      end

      def list
        IndexResponse.new(
          method: :list,
          response: connection.get("/databases")
        )
      end

      def describe(name)
        IndexResponse.new(
          method: :describe,
          response: connection.get("/databases/#{name}")
        )
      end

      def create(name, options = {})
        IndexResponse.new(
          method: :create,
          response: connection.post("/databases", create_payload(name, options))
        )
      end

      def delete(name)
        IndexResponse.new(
          method: :delete,
          response: connection.delete("/databases/#{name}")
        )
      end

      private

      attr_reader :connection

      def create_payload(name, options)
        options.merge({
          name: name
        })
      end
    end
  end
end