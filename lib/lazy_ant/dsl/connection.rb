require 'faraday'
require 'faraday_middleware'

module LazyAnt
  module DSL
    module Connection
      extend ActiveSupport::Concern
      attr_reader :default_params

      def connection
        return @connection if @connection
        @connection = Faraday.new(base_url) do |con|
          con.request request_type
          use_converter(con)
          con.response response_type
          con.response :raise_error
          con.adapter Faraday.default_adapter
          instance_exec(con, &default_callback) if default_callback
        end
        fix_params
      end

      def fix_params
        @default_params = @connection.params.dup
        @connection.params.clear
        @connection
      end

      def use_converter(con)
        if converter_block
          con.use LazyAnt::Converter, &converter_block
        elsif converter_name
          con.response converter_name
        end
      end

      def default_callback
        @default_callback ||=
          self.class.instance_variable_get(:@default_callback) ||
          @parent && @parent.default_callback
      end

      def converter_block
        @converter_block ||=
          self.class.instance_variable_get(:@converter_block) ||
          @parent && @parent.converter_block
      end

      def converter_name
        @coverter_name ||=
          self.class.instance_variable_get(:@converter_name) ||
          @parent && @parent.converter_name
      end

      def request_type
        @request_type ||=
          self.class.instance_variable_get(:@request_type) ||
          @parent && @parent.request_type || :json
      end

      def response_type
        @response_type ||=
          self.class.instance_variable_get(:@response_type) ||
          @parent && @parent.response_type || :json
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

        def converter(name = nil, &block)
          return @converter_block = block if block_given?
          @converter_name = name if name
        end

        def connection(&block)
          @default_callback = block
        end

        def request(type)
          @request_type = type
        end

        def response(type)
          @response_type = type
        end
      end
    end
  end
end
