require 'lazy_ant/dsl/grouping'
require 'lazy_ant/dsl/connection'

module LazyAnt
  module DSL
    module Endpoint
      extend ActiveSupport::Concern
      include DSL::Connection
      include Grouping

      module ClassMethods
        def api(name, options = {}, &block)
          method, path = endpoint(options)
          klazz = Class.new(LazyAnt::Endpoint) do
            send(method, path) if method && path
            instance_eval(&block) if block
          end
          converter = entity_converter(options)
          define_method name do |*args|
            response = klazz.new(*args).execute(connection)
            converter.call(response.body)
          end
        end

        protected

        def endpoint(options)
          method = [:get, :post, :put, :delete].find { |k| options[k] }
          return unless method
          path = options.delete(method)
          [method, path]
        end

        def entity_converter(entity: nil, multi: false)
          conv = entity ? ->(x) { entity.new(x) } : ->(x) { x }
          multi ? ->(x) { x.map(&conv) } : ->(x) { conv.call(x) }
        end
      end
    end
  end
end
