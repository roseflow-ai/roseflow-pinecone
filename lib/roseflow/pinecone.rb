# frozen_string_literal: true

require_relative "pinecone/version"

require "roseflow/pinecone/client"
require "roseflow/pinecone/collection"
require "roseflow/pinecone/config"
require "roseflow/pinecone/response"

require "dry-struct"

module Types
  include Dry.Types()
end

module Roseflow
  module Pinecone
    class Error < StandardError; end
    class IndexURLNotSetError < Error; end
  end
end

