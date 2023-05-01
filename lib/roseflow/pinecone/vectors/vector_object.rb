# frozen_string_literal: true

require "dry-struct"
require "dry-validation"

require "roseflow/pinecone/object"
require "roseflow/pinecone/vectors/sparse_vector"
require "roseflow/pinecone/vectors/common"

module Types
  include Dry.Types()

  Number = Types::Coercible::Float
  # SparseVector = Roseflow::Pinecone::Vector::SparseVector
end

module Roseflow
  module Pinecone
    class Vector
      class VectorObject < PineconeObject
        include Roseflow::Pinecone::Vectors::Common
        transform_keys(&:to_sym)

        class VectorObjectContract < Dry::Validation::Contract
          params do
            required(:id).filled(:string)
            required(:values).filled(:array)
            optional(:sparse_values).filled
            optional(:metadata).filled(:hash)
          end
        end
        
        contract_object VectorObjectContract

        attribute :id, Dry::Types['string']
        attribute :values, Dry::Types['array'].of(Types::Number)
        attribute? :score, Types::Number.optional
        attribute? :sparse_values, SparseVector.optional
        attribute? :metadata, Dry::Types['hash'].optional
      end
    end
  end
end