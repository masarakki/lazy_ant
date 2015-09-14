require 'spec_helper'

describe LazyAnt::DSL::Connection do
  let(:klazz) do
    Class.new do
      include LazyAnt::DSL::Connection

      base_url { config.dev ? 'http://dev.com' : 'http://prod.com' }
      connection do |conn|
        conn.headers['X-client-token'] = config.client_token
      end
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
end
