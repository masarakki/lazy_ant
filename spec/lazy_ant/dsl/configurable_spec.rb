require 'spec_helper'

describe LazyAnt::DSL::Configurable do
  let(:klazz) do
    Class.new do
      include LazyAnt::DSL::Configurable

      configurable :client_token, default: ''
      configurable :client_secret, default: ''
      configurable :dev?, default: false
    end
  end
  subject { klazz.new.config }
  it { is_expected.to be_a LazyAnt::Config }
  it { is_expected.to respond_to :client_token }
  it { is_expected.not_to be_dev }
end
