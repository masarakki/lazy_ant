module LazyAnt
  class Config
    def initialize
      self.class.keys.each do |var, options|
        instance_variable_set(var, options[:default])
      end
    end

    def deprecated(method, instead)
      msg = "config.#{method} is deprecated"
      if instead.is_a?(Symbol)
        writer, = self.class.accessor_methods(instead)
        msg += ", use config.#{writer}"
      end
      warn msg
    end

    def validate(val)
      fail ArgumentError unless val == true || val == false
    end

    class << self
      def key(name, options = {})
        writer, reader, var, question = accessor_methods(name)
        options[:question] = question
        keys[var] = options

        define_writer(writer, var, options)
        define_reader(reader, var, options)
      end

      def define_writer(writer, var, options = {})
        define_method writer do |val|
          deprecated writer, options[:deprecated] if options[:deprecated]
          validate(val) if options[:question]
          instance_variable_set(var, val)
        end
      end

      def define_reader(reader, var, _options = {})
        define_method reader do
          instance_variable_get(var)
        end
      end

      def keys
        @keys ||= {}
      end

      def accessor_methods(name)
        attr = name.to_s.gsub(/[!\?]$/, '')
        var = "@#{attr}".to_sym
        ["#{attr}=".to_sym, name.to_sym, var, name[-1] == '?']
      end
    end
  end
end
