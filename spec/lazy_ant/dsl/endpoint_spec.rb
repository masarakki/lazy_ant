require 'spec_helper'

describe LazyAnt::DSL::Endpoint do
  let(:klazz) do
    class Post < OpenStruct
    end

    Class.new do
      include LazyAnt::DSL::Endpoint
      include LazyAnt::DSL::Connection

      api :find, get: '/users/:user_id/posts/:id', entity: Post
      api :search, get: '/users/:user_id/posts', multi: true, entity: Post
      api :block, entity: Post do
        get '/hello/:user_id/world/:id'
      end
    end
  end

  let(:api) { klazz.new }
  it { expect(api).to be_respond_to :find }
  before { allow(api).to receive(:base_url) { 'http://example.com' } }

  describe 'invalid arguments' do
    it do
      expect { api.find(10) }.to raise_error ArgumentError
    end
  end

  describe 'valid arguments' do
    context 'signle resource' do
      let(:post) { api.find(100, 10) }
      let(:url) { 'http://example.com/users/100/posts/10' }
      subject { post }

      context 'success' do
        before { stub_request(:get, url).to_return(status: 200, body: '{"id": 1, "body": "hello"}') }

        it { is_expected.to be_a Post }
        its(:id) { is_expected.to eq 1 }
        its(:body) { is_expected.to eq 'hello' }
      end

      context 'error' do
        before { stub_request(:get, url).to_return(status: 404, body: '') }
        it { expect { post }.to raise_error Faraday::Error::ResourceNotFound }
      end
    end

    context 'block' do
      let(:post) { api.block(100, 10) }
      let(:url) { 'http://example.com/hello/100/world/10' }
      subject { post }

      before { stub_request(:get, url).to_return(status: 200, body: '{"id": 1, "body": "hello"}') }

      it { is_expected.to be_a Post }
      its(:id) { is_expected.to eq 1 }
      its(:body) { is_expected.to eq 'hello' }
    end

    context 'multiple resources' do
      let(:posts) { api.search(100, q: 'hello') }
      let(:url) { 'http://example.com/users/100/posts?q=hello' }
      subject { posts }
      before { stub_request(:get, url).to_return(status: 200, body: '[{"id": 1, "body": "aaaa"},{"id": 2, "body": "bbbb"}]') }

      it { is_expected.to be_a Array }
      its(:count) { is_expected.to eq 2 }
      its(:first) { is_expected.to be_a Post }
      its('first.id') { is_expected.to eq 1 }
    end
  end
end
