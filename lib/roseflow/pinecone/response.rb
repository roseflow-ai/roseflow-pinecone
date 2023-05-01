# frozen_string_literal: true

module Roseflow
  module Pinecone
    class BaseResponse
      attr_reader :body
      attr_reader :status
      attr_reader :object

      def initialize(method:, response:)
        @response = response
        @method_ = method
        handle_response
      end

      def success?
        @response.success?
      end

      private

      attr_reader :response
    end

    class CollectionResponse < BaseResponse
      private

      def handle_response
        case @method_
        when :list
          @body = JSON.parse(response.body)
        when :describe
          if response.body.match(/{*.}/)
            @body = JSON.parse(response.body)
            @object = Collection::Description.new(@body)
          end
        when :create
          if response.body.match(/{*.}/)
            @body = JSON.parse(response.body)
          else
            @body = response.body
          end
        end
        @status = response.status
      end
    end

    class VectorResponse < BaseResponse
      attr_reader :upsert_count, :vectors

      def upsert_count
        @body.fetch("upsertedCount")
      end

      def message
        @body.fetch("message")
      end

      def success?
        @response.success? && @status == 200
      end

      def failure?
        !success?
      end

      def vectors
        @vectors.map do |vector|
          Vector::VectorObject.new(vector.last)
        end
      end
      
      private

      def handle_response
        case @method_
        when :upsert
          @body = JSON.parse(@response.body)
        when :delete
          @body = JSON.parse(@response.body)
        when :update
          @body = JSON.parse(@response.body)
        end
        @status = response.status
      end
    end

    class VectorQueryResponse < VectorResponse
      def vectors
        case @method_
        when :fetch
          @vectors.map do |vector|
            Vector::VectorObject.new(vector.last)
          end
        when :query
          @vectors.map do |vector|
            Vector::VectorObject.new(vector)
          end
        end
      end

      private

      def handle_response
        case @method_
        when :fetch
          @body = JSON.parse(@response.body)
          @vectors = @body["vectors"]
        when :query
          @body = JSON.parse(@response.body)
          @vectors = @body["matches"]
        end
        @status = @response.status
      end
    end

    class IndexResponse < BaseResponse      
      private

      def handle_response
        case @method_
        when :list
          @body = JSON.parse(@response.body)
        when :describe
          if @response.body.match(/{*.}/)
            @body = JSON.parse(@response.body)
            attrs = @body["database"].merge({ status: @body["status"] })
            @object = Index::Description.new(attrs)
          end
        when :create
          if @response.body.match(/{*.}/)
            @body = JSON.parse(@response.body)
          else
            @body = @response.body
          end
        end

        @status = @response.status
      end
    end
  end
end