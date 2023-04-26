# frozen_string_literal: true

require "anyway_config"

module Roseflow
  module Pinecone
    class Config < Anyway::Config
      config_name :pinecone

      attr_config :api_key, :environment

      required :api_key
      required :environment
    end
  end
end