module LazyAnt
  class Group
    mattr_accessor :name, instance_writer: false, instance_reader: false
    def inspect
      "<LazyAnt::Group #{name}>"
    end
    include LazyAnt::DSL::Endpoint

    def name
      self.class.name
    end

    def self.name=(name)
      @name = name.to_s
    end

    class << self
      attr_reader :name
    end
  end
end
