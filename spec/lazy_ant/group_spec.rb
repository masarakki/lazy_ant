require 'spec_helper'

describe LazyAnt::Group do
  let(:client) do
    MyClient.new do |config|
      config.client_token = 'token'
    end
  end
  let(:simple_group) do
    Class.new described_class do
      self.name = :a
    end
  end
  let(:new_url_group) do
    Class.new described_class do
      self.name = :b
      connection do |config|
        config.response :json
      end
      base_url 'http://api2.example.com'
    end
  end
  subject { group }
  context 'simple group' do
    let(:group) { simple_group.new(client) }
    its(:base_url) { is_expected.to eq 'http://api.example.com' }
    its(:name) { is_expected.to eq 'a' }
    it do
      expect(group).to receive(:base_url).and_call_original
      group.connection
    end
    it do
      expect(client).to receive(:default_callback).and_call_original
      group.connection
    end
  end
  context 'given other url' do
    let(:group) { new_url_group.new(client) }
    its(:base_url) { is_expected.to eq 'http://api2.example.com' }
    its(:name) { is_expected.to eq 'b' }
    it do
      expect(client).not_to receive(:default_callback)
      group.connection
    end
  end
end
