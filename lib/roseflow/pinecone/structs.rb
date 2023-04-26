require "dry-struct"

module Types
  include Dry.Types()
end

module Roseflow
  module Pinecone
    class Index
      class Status < Dry::Struct
        transform_keys(&:to_sym)

        attribute :host, Types::Strict::String
        attribute :port, Types::Strict::Integer
        attribute :state, Types::Strict::String
        attribute :ready, Types::Strict::Bool
      end

      class Description < Dry::Struct
        transform_keys(&:to_sym)

        attribute :name, Types::Strict::String
        attribute :metric, Types::Strict::String
        attribute :dimension, Types::Strict::Integer
        attribute :replicas, Types::Strict::Integer
        attribute :shards, Types::Strict::Integer
        attribute :pods, Types::Strict::Integer
        attribute :pod_type, Types::Strict::String

        attribute :status, Status
      end
    end

    class Collection
      class Description < Dry::Struct
        transform_keys(&:to_sym)

        attribute :name, Types::Strict::String
        attribute :status, Types::Strict::String
        attribute :size, Types::Strict::Integer.default(0)
      end
    end
  end
end