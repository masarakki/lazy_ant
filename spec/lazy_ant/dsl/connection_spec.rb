require 'spec_helper'

describe LazyAnt::DSL::Connection do
  let!(:converter) do
    Class.new Faraday::Response::Middleware do
      def on_complete(env)
        env.body = env.body['data'] if env.status == 200
      end
      Faraday::Response.register_middleware my_converter: self
    end
  end

  let(:klazz) do
    Class.new do
      include LazyAnt::DSL::Connection

      base_url { config.dev ? 'http://dev.com' : 'http://prod.com' }
      connection do |conn|
        conn.headers['X-client-token'] = config.client_token
      end

      converter :my_converter
    end
  end

  let(:client) { klazz.new }
  let(:connection) { client.connection }
  let(:token) { 'sample-token' }
  before { allow(client).to receive(:config) { double(client_token: token, dev: true) } }
  describe '#client' do
    subject { connection }
    it { is_expected.to be_a Faraday::Connection }
    its('url_prefix.to_s') { is_expected.to eq 'http://dev.com/' }
    describe 'haders' do
      subject { connection.headers }
      its(['X-client-token']) { is_expected.to eq token }
    end
  end
  describe 'base_url' do
    subject { client }
    its(:base_url) { is_expected.to eq 'http://dev.com' }
  end

  describe 'converter' do
    let(:body) { '{"data": {"id": 1}, "status": 200, "error": []}' }
    before { stub_request(:get, 'http://dev.com/').and_return(status: 200, body: body) }
    subject { connection.get '/' }

    its(:body) { is_expected.to eq 'id' => 1 }
  end

  describe '.base_url' do
    before { allow(client).to receive(:config) { double(client_token: token, dev: true) } }
    context 'with callable' do
      let(:client) { klazz.new }
      let(:klazz) do
        Class.new do
          include LazyAnt::DSL::Connection

          def self.base_urls(prod, dev)
            proc do
              url = config.dev ? dev : prod
              "http://#{url}"
            end
          end
          base_url(&base_urls('a.com', 'b.com'))
        end
      end
      it { expect(client.base_url).to eq 'http://b.com' }
    end
  end
end
