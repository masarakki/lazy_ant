module LazyAnt
  #
  # Endpoint Definition
  #
  # (in dsl)
  # api :echo do
  #   get '/echo'
  #   param :hello, default: 'world', required: true, rename: 'SHIT_KEY'
  # end
  #
  # client.echo(hello: 'test')
  # => GET '/echo?SHIT_KEY=test'
  #
  class Endpoint
    class_attribute :verb, :path, :params

    def initialize(*args)
      @query = default_query.merge(args.extract_options!)
      @url = build_url(*args)
    end

    def execute(connection)
      @query = connection.params.merge(@query)
      validate!
      connection.send(verb, @url, renamed_query) do |req|
        req.params.clear if [:put, :post].include?(req.method)
      end
    end

    protected

    def validate!
      params.select { |_k, v| v[:required] }.each do |k, _v|
        fail ArgumentError, "params[:#{k}] is required!" unless @query[k]
      end
    end

    def build_url(*args)
      args = Array(args)
      url = path.dup
      arg_names = url.scan(/:([\w_]+)/).map(&:first)
      arg_names.each do |k|
        arg = args.shift
        fail ArgumentError, "missing required key :#{k}" unless arg
        url.gsub!(/:#{k}/, arg.to_s)
      end
      url
    end

    def default_query
      res = {}
      params.each do |k, v|
        res[k] = v[:default] if v[:default]
        res
      end
      res
    end

    def renamed_query
      query = @query.dup
      params.each do |k, v|
        if v[:rename]
          query[v[:rename]] = query[k]
          query.delete k
        end
      end
      query
    end

    class << self
      %w(get put post delete).each do |verb|
        class_eval(<<-EOS, __FILE__, __LINE__ + 1)
          def #{verb}(path)
            self.verb = :#{verb}
            self.path = path
          end
        EOS
      end

      def param(name, options = {})
        params[name] = options
      end

      def inherited(child)
        child.params = {}
      end
    end
  end
end
