require 'faraday'
require 'faraday_middleware'

module LazyAnt
  module DSL
    module Connection
      extend ActiveSupport::Concern

      def connection
        @connection ||= Faraday.new(base_url) do |con|
          con.request :url_encoded
          con.request :json
          con.response converter_name if converter_name
          con.response :json
          con.response :raise_error
          con.adapter Faraday.default_adapter
          instance_exec(con, &default_callback) if default_callback
        end
      end

      def default_callback
        @default_callback ||=
          self.class.instance_variable_get(:@default_callback) ||
          @parent && @parent.default_callback
      end

      def converter_name
        @coverter_name ||=
          self.class.instance_variable_get(:@converter_name) ||
          @parent && @parent.converter_name
      end

      module ClassMethods
        def base_url(url = nil, &block)
          if block_given?
            define_method :base_url do
              @base_url ||= instance_eval(&block)
            end
          else
            define_method :base_url do
              url
            end
          end
        end

        def converter(name)
          @converter_name = name
        end

        def connection(&block)
          @default_callback = block
        end
      end
    end
  end
end
