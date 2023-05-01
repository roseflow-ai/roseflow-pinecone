# frozen_string_literal: true

require "faraday"
require "faraday/retry"

require "roseflow/pinecone/index"
require "roseflow/pinecone/vector"

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
        @index ||= get_vector_index(name)
      end
      
      private

      def get_vector_index(name)
        return Vector.new(index_connection(index_url)) if index_url && index_url.match(/#{name}/)
        @index_url = describe_index(name).object.status.host
        return Vector.new(index_connection(@index_url))
      end

      def environment_url(env)
        "https://controller.#{env}.pinecone.io"
      end

      def index_url_for(url)
        "https://#{url}"
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

      def index_connection(index_url = nil)
        raise IndexURLNotSetError, "You must provide index URL to access an index" unless index_url
        @index_connection ||= Faraday.new(
          url: index_url_for(index_url),
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