# frozen_string_literal: true

require "dry-struct"
require "dry-validation"

require "roseflow/pinecone/object"
require "roseflow/pinecone/vectors/sparse_vector"
require "roseflow/pinecone/vectors/common"

module Types
  include Dry.Types()
end

module Roseflow
  module Pinecone
    class Vector
      class Update < PineconeObject
        include Roseflow::Pinecone::Vectors::Common

        class UpdateContract < Dry::Validation::Contract
          params do
            required(:id).filled(:string)
            optional(:namespace).filled(:string)
            optional(:vectors).filled(:array)
            optional(:sparse_values).filled
            optional(:metadata).filled(:hash)
          end
        end

        contract_object UpdateContract

        attribute :id, Dry::Types['string']
        attribute? :namespace, Dry::Types['string'].optional
        attribute? :vectors, Dry::Types['array'].of(Dry::Types['float']).optional
        attribute? :sparse_values, SparseVector.optional
        attribute? :metadata, Dry::Types['hash'].optional
      end
    end
  end
end