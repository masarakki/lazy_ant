require 'spec_helper'

RSpec.describe LazyAnt::DSL do
  it { expect(MyClient::Config).not_to be_nil }

  before { MyClient.instance_variable_set(:@global_config, nil) }

  describe 'configuration' do
    subject { client.config }
    describe '#initialize' do
      context 'without block' do
        let(:client) { MyClient.new }
        its(:client_token) { is_expected.to eq '' }
        it { is_expected.to be_frozen }
      end

      context 'with block' do
        let(:client) do
          MyClient.new do |conf|
            conf.client_token = 'token'
          end
        end
        its(:client_token) { is_expected.to eq 'token' }
        it { is_expected.to be_frozen }
      end
    end

    describe '.setup' do
      before do
        MyClient.setup do |conf|
          conf.client_token = 'token'
        end
      end

      context 'without block' do
        let(:client) { MyClient.new }
        its(:client_token) { is_expected.to eq 'token' }
        it { is_expected.to be_frozen }
      end

      context 'with block' do
        let(:client) do
          MyClient.new do |conf|
            conf.client_token = 'hello'
          end
        end
        its(:client_token) { is_expected.to eq 'hello' }
        it { is_expected.to be_frozen }
      end
    end
  end

  describe 'connection' do
    let(:client) do
      MyClient.new do |conf|
        conf.client_token = 'token'
      end
    end
    it { expect(client.connection).to be_a Faraday::Connection }
  end

  describe 'request and response' do
    let(:client) { MyClient.new }
    it do
      stub_request(:post, 'http://api.example.com/version.xml').with(
        body: { hello: 'world' },
        headers: { 'Content-Type' => 'application/x-www-form-urlencoded' }
      ).to_return(body: '<data><version>1.1</version></data>', status: 200)
      res = client.request_and_response.version(hello: 'world')
      expect(res).to eq 'version' => '1.1'
    end

    it do
      stub_request(:post, 'http://api.example.com/version.json').with(
        body: { hello: 'world' },
        headers: { 'Content-Type' => 'application/json' }
      ).to_return(body: '{"data": { "version": "1.1" } }', status: 200)
      res = client.version(hello: 'world')
      expect(res).to eq 'version' => '1.1'
    end
  end

  describe 'api' do
    let(:client) do
      MyClient.new do |config|
        config.client_token = 'token'
      end
    end
    it { expect(client.users.base_url).to eq 'http://api.example.com' }
    it { expect(client.users.posts.base_url).to eq 'http://api2.example.com' }
    it do
      stub_request(:get, 'http://api.example.com/users/1.json').to_return(status: 200, body: '{"data": {"id": 1, "name": "masarakki"}}')
      user = client.users.find(1)
      expect(user.id).to eq 1
      expect(user.name).to eq 'masarakki'
    end

    it do
      stub_request(:post, 'http://api.example.com/version.json').to_return(status: 200, body: '{"data": {"version": "1.0.0"}}')
      version = client.version
      expect(version['version']).to eq '1.0.0'
    end

    it do
      stub_request(:get, 'http://api2.example.com/users/10/posts/1.json').with(headers: { 'X-Client-Token' => 'token' }).to_return(status: 200, body: '{"data": {"user_id": 10, "id": 1}}')
      post = client.users.posts.find(10, 1)
      expect(post).to eq 'user_id' => 10, 'id' => 1
    end
  end
end
