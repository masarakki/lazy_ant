module LazyAnt
  class Group
    def initialize(parent)
      @parent = parent
    end

    def inspect
      "<LazyAnt::Group #{name}>"
    end
    include LazyAnt::DSL::Endpoint

    def name
      self.class.name
    end

    def connection
      @parent.connection
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
