# frozen_string_literal: true

module Roseflow
  module Pinecone
    module Vectors
      module Common
        def self.extended(base_class)
          base_class.extend ClassMethods
        end

        def self.included(base_class)
          base_class.extend ClassMethods
        end

        module ClassMethods
          def self.new(input)
            validation = self.contract_object.new.call(input)
            if validation.success?
              super(input)
            else
              raise ArgumentError.new(validation.errors.to_h.inspect)
            end
          end
        end

        def to_json
          to_h.map do |key, value|
            [key.to_s.split("_").map.with_index do |word, index|
              index == 0 ? word : word.capitalize
            end.join.to_sym, value]
          end.to_h.to_json
        end
      end
    end
  end
end