# frozen_string_literal: true

require "dry-struct"
require "dry-validation"

require "roseflow/pinecone/object"
require "roseflow/pinecone/vectors/filter"
require "roseflow/pinecone/vectors/common"

module Types
  include Dry.Types()
end

module Roseflow
  module Pinecone
    class Vector
      class Deletion < PineconeObject
        include Roseflow::Pinecone::Vectors::Common

        class DeletionContract < Dry::Validation::Contract
          params do
            optional(:ids).filled(:array)
            optional(:namespace).filled(:string)
            optional(:filter).filled
            optional(:delete_all).filled(:bool)
          end
        end

        contract_object DeletionContract

        attribute? :ids, Dry::Types['array'].of(Dry::Types['string'])
        attribute? :namespace, Dry::Types['string']
        attribute? :filter, Types.Instance(Filter)
        attribute? :delete_all, Dry::Types['bool'].default(false)
      end
    end
  end
end