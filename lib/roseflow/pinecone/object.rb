# frozen_string_literal: true

require "dry-struct"

module Roseflow
  module Pinecone
    class PineconeObject < Dry::Struct
      defines :contract_object
    end
  end
end