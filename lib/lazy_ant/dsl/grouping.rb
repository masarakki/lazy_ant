module LazyAnt
  module DSL
    module Grouping
      extend ActiveSupport::Concern

      module ClassMethods
        def group(name, &block)
          base = self.respond_to?(:name) ? self.name : nil
          group_name = [base, name].compact.join('.')
          group_class = Class.new(LazyAnt::Group) do
            self.name = group_name
            instance_eval(&block) if block
          end
          define_method name do
            group_class.new(self)
          end
        end
      end
    end
  end
end
