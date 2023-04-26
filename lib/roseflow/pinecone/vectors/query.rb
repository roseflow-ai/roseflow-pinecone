# frozen_string_literal: true

require "dry-struct"
require "dry-validation"

require "roseflow/pinecone/vectors/filter"
require "roseflow/pinecone/vectors/sparse_vector"

module Types
  include Dry.Types()
end

module Roseflow
  module Pinecone
    class Vector
      class Query < PineconeObject
        include Roseflow::Pinecone::Vectors::Common

        class QueryContract < Dry::Validation::Contract
          params do
            optional(:vector).filled(:array)
            optional(:id).filled(:string)
          end

          rule(:vector, :id) do
            if !values[:vector].nil? && !values[:id].nil?
              key(:vector).failure("Only one of vector or id can be specified")
              key(:id).failure("Only one of vector or id can be specified")
            end
          end
        end

        contract_object QueryContract

        schema schema.strict

        attribute :namespace, Dry::Types['string'].default("")
        attribute :include_values, Dry::Types['bool'].default(false)
        attribute :include_metadata, Dry::Types['bool'].default(true)
        attribute :top_k, Dry::Types['integer'].default(10)
        attribute? :vector, Dry::Types['array'].of(Dry::Types['float'] | Dry::Types['integer'])
        attribute? :filter, Filter
        attribute? :sparse_vector, SparseVector
        attribute? :id, Dry::Types['string']

        def self.new(input)
          validation = self.contract_object.new.call(input)
          if validation.success?
            super(input)
          else
            raise ArgumentError.new(validation.errors.to_h.inspect)
          end
        end
      end
    end
  end
end