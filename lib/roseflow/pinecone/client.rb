# frozen_string_literal: true

require "faraday"
require "faraday/retry"

require "roseflow/pinecone/index"

module Roseflow
  module Pinecone
    class Client
      attr_accessor :index_url
      
      def initialize(config = Config.new)
        @environment = config.environment
        @api_key = config.api_key
        @index_url = nil
      end

      def indices
        Index.new(connection).list.body
      end
      
      alias_method :indexes, :indices

      def describe_index(name)
        Index.new(connection).describe(name)
      end

      def create_index(name, options = {})
        Index.new(connection).create(name, options)
      end

      def delete_index(name)
        Index.new(connection).delete(name)
      end

      def collections
        Collection.new(connection).list
      end

      def describe_collection(name)
        Collection.new(connection).describe(name)
      end

      def create_collection(name, source)
        Collection.new(connection).create(name, source)
      end

      def delete_collection(name)
        Collection.new(connection).delete(name)
      end

      def index(name)
        @index ||= Vector.new(index_connection, name)
      end
      
      private

      def environment_url(region)
        "https://controller.#{region}.pinecone.io"
      end

      def index_url(index)
        raise NotImplementedError
      end
      
      def connection
        @connection ||= Faraday.new(
          url: environment_url(@environment),
          headers: {
            "accept": "application/json; charset=utf-8",
            "Api-Key": @api_key,
          }
        ) do |faraday|
          faraday.request :json
          faraday.adapter Faraday.default_adapter
        end
      end

      def index_connection(index = nil)
        @connection ||= Faraday.new(
          url: index_url(index),
          headers: {
            "accept": "application/json; charset=utf-8",
            "Api-Key": @api_key,
          }
        ) do |faraday|
          faraday.request :json
          faraday.adapter Faraday.default_adapter
        end
      end
    end
  end
end