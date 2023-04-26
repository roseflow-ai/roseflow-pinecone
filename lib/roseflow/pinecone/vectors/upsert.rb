# frozen_string_literal: true

require "dry-struct"

require "roseflow/pinecone/object"
require "roseflow/pinecone/vectors/sparse_vector"
require "roseflow/pinecone/vectors/vector_object"
require "roseflow/pinecone/vectors/common"

module Types
  include Dry.Types()
end

module Roseflow
  module Pinecone
    class Vector
      class Upsert < PineconeObject
        include Roseflow::Pinecone::Vectors::Common

        class UpsertContract < Dry::Validation::Contract
          params do
            required(:vectors).filled(:array)
            optional(:namespace).filled(:string)
          end
        end

        contract_object UpsertContract

        attribute :vectors, Dry::Types['array'].of(VectorObject)
        attribute? :namespace, Dry::Types['string'].optional

        def self.from(data)
          raise ArgumentError, "Data must be a valid upsert hash" unless data.is_a?(Hash) && data.keys.include?(:vectors)
          new(
            vectors: data[:vectors].map { |vector| VectorObject.new(id: vector[:id], values: vector[:values]) },
            namespace: data[:namespace]
          )
        end
      end
    end
  end
end