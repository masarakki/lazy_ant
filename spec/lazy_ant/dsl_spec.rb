require 'spec_helper'

class MyClient
  class User ; end

  include LazyAnt::DSL

  configurable :client_token, default: ''
  configurable :client_secret, default: ''
  configurable :dev?, default: false

  base_url 'http://api.example.com'

  connection do |faraday|
    faraday.headers['X-client-token'] = config.client_token
  end

  group :users do
    api :find, get: '/users/:id.json', entity: User
  end
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
end
