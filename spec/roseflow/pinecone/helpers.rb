# frozen_string_literal: true

require "faraday"
require "faraday/retry"
require "roseflow/pinecone/config"

def pinecone_connection(config = Roseflow::Pinecone::Config.new)
  connection = Faraday.new(
    url: "https://controller.#{config.environment}.pinecone.io",
    headers: {
      "accept": "application/json; charset=utf-8",
      "Api-Key": config.api_key
    }
  ) do |faraday|
    faraday.request :json
    faraday.adapter Faraday.default_adapter
  end
end