module LazyAnt
  class Group
    include LazyAnt::DSL::Endpoint

    def initialize(parent)
      @parent = parent
    end

    def inspect
      "<LazyAnt::Group #{name}>"
    end

    def config
      @parent.config
    end

    def base_url
      @parent.base_url
    end

    def name
      self.class.name
    end

    def self.name=(name)
      @name = name.to_s
    end

    class << self
      attr_reader :name
      attr_accessor :parent
    end
  end
end
