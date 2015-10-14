require 'lazy_ant/dsl/grouping'
require 'lazy_ant/dsl/connection'

module LazyAnt
  module DSL
    module Endpoint
      extend ActiveSupport::Concern
      include DSL::Connection
      include Grouping

      def update_params(req)
        case req.method
        when :get, :head, :delete
          default_params.each { |k, v| req.params[k] = v }
        when :post, :put
          default_params.each { |k, v| req.body[k] = v }
        end
        yield(req) if block_given?
      end

      module ClassMethods
        def api(name, options = {}, &block)
          method, path = endpoint(options)
          converter = entity_converter(options)
          define_method name do |*args|
            params = args.extract_options!
            path = generate_url(path, args)
            response = connection.send(method, path, params) do |req|
              update_params(req, &block)
            end
            converter.call(response.body)
          end
        end

        protected

        def endpoint(options)
          method = [:get, :post, :put, :delete].find { |k| options[k] }
          fail 'Request url not given' unless method
          path = options.delete(method)
          [method, path]
        end

        def entity_converter(entity: nil, multi: false)
          conv = entity ? ->(x) { entity.new(x) } : ->(x) { x }
          multi ? -> (x) { x.map(&conv) } : -> (x) { conv.call(x) }
        end
      end

      protected

      def generate_url(path, args)
        arg_names = path.scan(/:([\w_]+)/).map(&:first)
        arg_names.each do |k|
          arg = args.shift
          fail ArgumentError, "missing required key :#{k}" unless arg
          path = path.gsub(/:#{k}/, arg.to_s)
        end
        path
      end
    end
  end
end
