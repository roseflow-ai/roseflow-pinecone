# frozen_string_literal: true

require "dry-struct"
require "dry-validation"

require "roseflow/pinecone/object"
require "roseflow/pinecone/vectors/common"

module Types
  include Dry.Types()
end

module Roseflow
  module Pinecone
    class Vector
      class SparseVector < PineconeObject
        include Roseflow::Pinecone::Vectors::Common

        class SparseVectorContract < Dry::Validation::Contract
          params do
            required(:indices).filled(:array)
            required(:values).filled(:array)
          end

          rule(:indices, :values) do
            unless values[:indices].size === values[:values].size
              key(:indices).failure("Indices and values must be the same size")
              key(:values).failure("Indices and values must be the same size")
            end
          end
        end

        contract_object SparseVectorContract

        attribute :indices, Dry::Types['array'].of(Dry::Types['integer'])
        attribute :values, Dry::Types['array'].of(Dry::Types['float'] | Dry::Types['integer'])
      end
    end
  end
end