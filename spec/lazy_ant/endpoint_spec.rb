require 'spec_helper'

describe LazyAnt::Endpoint do
  let(:klazz) do
    Class.new(LazyAnt::Endpoint) do
      post '/hello/:world'
      param :key1, rename: :KEY1
      param :key2, required: true
      param :key3, default: 'HELLO'
    end
  end

  let(:connection) do
    Faraday.new('http://example.com') do |con|
      con.params[:foo] = 'bar'
      con.request :json
      con.response :json
      con.adapter Faraday.default_adapter
    end
  end

  let(:endpoint) { klazz.new(1, key1: 'key1', key2: 'key2') }
  subject { endpoint }
  its(:verb) { is_expected.to eq :post }
  its(:path) { is_expected.to eq '/hello/:world' }
  its('params.keys') { is_expected.to eq %i(key1 key2 key3) }
  its(:default_query) { is_expected.to eq key3: 'HELLO' }

  describe '#build_url' do
    it do
      expect(endpoint.send(:build_url, 1)).to eq '/hello/1'
    end
    it do
      expect { endpoint.send(:build_url) }.to raise_error ArgumentError
    end
  end

  its(:renamed_query) { is_expected.to eq KEY1: 'key1', key2: 'key2', key3: 'HELLO' }

  describe '#validate!' do
    let(:endpoint) { klazz.new }
    it { expect { endpoint.validate! }.to raise_error ArgumentError }
    it { expect { endpoint.execute(connection) }.to raise_error ArgumentError }
  end

  describe '#execute' do
    let(:connection) do
      Faraday.new('http://example.com') do |con|
        con.params[:foo] = 'bar'
        con.request :json
        con.response :json
        con.adapter Faraday.default_adapter
      end
    end

    it do
      stub_request(:post, 'http://example.com/hello/1').with(
        body: { foo: 'bar', KEY1: 'key1', key2: 'key2', key3: 'HELLO' }
      ).to_return(body: '{"id": 1}')
      res = endpoint.execute(connection)
      expect(res.body).to eq 'id' => 1
    end
  end

  it do
    #    endpoint.execute(1, hello: 'world')
  end

  describe 'isolated' do
    let(:klazz2) do
      Class.new(LazyAnt::Endpoint) do
        get '/hello/:world/:id'
      end
    end
    before { klazz && klazz2 }
    it { expect(klazz.path).to eq '/hello/:world' }
    it { expect(klazz2.path).to eq '/hello/:world/:id' }
  end
end
