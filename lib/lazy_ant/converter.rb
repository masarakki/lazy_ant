module LazyAnt
  # Simple Converter
  #
  # conn.use LazyAnt::Converter do |env|
  #  env.body = body['data']
  # end
  #
  class Converter < Faraday::Response::Middleware
    def initialize(app, &block)
      super
      @block = block
    end

    def on_complete(env)
      @block.call(env)
    end
  end
end
