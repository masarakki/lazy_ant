require 'lazy_ant/dsl/grouping'
require 'lazy_ant/dsl/connection'

module LazyAnt
  module DSL
    module Endpoint
      extend ActiveSupport::Concern
      include DSL::Connection
      include Grouping

      module ClassMethods
        def api(name, options = {})
          method, path = endpoint(options)
          arg_names =  path.scan(/:([\w_]+)/).map(&:first)
          define_method name do |*args|
            params = args.extract_options!
            arg_names.each do |k|
              arg = args.shift
              fail ArgumentError, "missing required key :#{k}" unless arg
              path = path.gsub(/:#{k}/, arg.to_s)
            end
            response = connection.send(method, path, params)
            converter = options[:entity] ? -> (x) { options[:entity].new(x) } : -> (x) { x }
            if options[:multi]
              response.body.map(&converter)
            else
              converter.call(response.body)
            end
          end
        end

        protected

        def endpoint(options)
          method = [:get, :post, :put, :delete].find { |k| options[k] }
          fail 'Request url not given' unless method
          path = options.delete(method)
          [method, path]
        end
      end
    end
  end
end
