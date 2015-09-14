module LazyAnt
  class Config
    def initialize
      self.class.keys.each do |var, options|
        instance_variable_set(var, options[:default])
      end
    end

    def self.key(name, options = {})
      attr = name.to_s.gsub(/[!\?]$/, '')
      var = "@#{attr}".to_sym
      keys[var] = options

      define_method "#{attr}=" do |val|
        fail ArgumentError unless name.to_s[-1] != '?' || val == false || val == true
        instance_variable_set(var, val)
      end

      define_method name do
        instance_variable_get(var)
      end
    end

    def self.keys
      @keys ||= {}
    end
  end
end
