module LazyAnt
  module DSL
    module Configurable
      extend ActiveSupport::Concern

      def config
        @config ||= self.class.global_config.dup
      end

      module ClassMethods
        def global_config
          @global_config ||= config_class.new
        end

        protected

        def configurable(name, options)
          config_class.key name, options
        end

        def config_class
          @config_class ||= const_set('Config', Class.new(LazyAnt::Config))
        end
      end
    end
  end
end
