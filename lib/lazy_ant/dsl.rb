require 'lazy_ant/dsl/configurable'
require 'lazy_ant/dsl/endpoint'
require 'lazy_ant/dsl/connection'

module LazyAnt
  module DSL
    extend ActiveSupport::Concern
    include Configurable
    include Endpoint
    include Connection

    def initialize
      yield config if block_given?
      config.freeze
      config.connection_callbacks.each do |callback|
        instance_callbacks.push callback
      end
    end

    module ClassMethods
      def setup
        yield global_config
        global_config.freeze
      end
    end
  end
end
