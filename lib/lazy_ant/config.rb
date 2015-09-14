module LazyAnt
  class Config
    def initialize
      self.class.keys.each do |var, options|
        instance_variable_set(var, options[:default])
      end
    end

    def self.key(name, options = {})
      writer, reader, var, question = accessor_methods(name)
      keys[var] = options

      define_method writer do |val|
        fail ArgumentError unless !question || val == false || val == true
        instance_variable_set(var, val)
      end

      define_method reader do
        instance_variable_get(var)
      end
    end

    def self.keys
      @keys ||= {}
    end

    def self.accessor_methods(name)
      attr = name.to_s.gsub(/[!\?]$/, '')
      var = "@#{attr}".to_sym
      ["#{attr}=".to_sym, name.to_sym, var, name[-1] == '?']
    end
  end
end
