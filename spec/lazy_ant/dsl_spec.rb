require 'spec_helper'
require 'active_model'

class MyClient
  class User
    include ActiveModel::Model
    attr_accessor :id, :name
  end

  class DataPicker < Faraday::Response::Middleware
    def on_complete(env)
      env.body = env.body['data']
    end
    Faraday::Response.register_middleware data_picker: self
  end

  include LazyAnt::DSL

  configurable :client_token, default: ''
  configurable :client_secret, default: ''
  configurable :dev?, default: false

  base_url 'http://api.example.com'

  connection do |faraday|
    faraday.headers['X-client-token'] = config.client_token
  end

  converter :data_picker

  group :users do
    api :find, get: '/users/:id.json', entity: User
  end

  api :version, get: '/version.json'
end

RSpec.describe LazyAnt::DSL do
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

  describe 'api' do
    let(:client) { MyClient.new }
    it do
      stub_request(:get, 'http://api.example.com/users/1.json').to_return(status: 200, body: '{"data": {"id": 1, "name": "masarakki"}}')
      user = client.users.find(1)
      expect(user.id).to eq 1
      expect(user.name).to eq 'masarakki'
    end

    it do
      stub_request(:get, 'http://api.example.com/version.json').to_return(status: 200, body: '{"data": {"version": "1.0.0"}}')
      version = client.version
      expect(version['version']).to eq '1.0.0'
    end
  end
end
