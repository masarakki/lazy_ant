require 'spec_helper'

describe LazyAnt::Config do
  let(:klass) do
    Class.new(described_class) do
      key :hello, default: 'world'
      key :world
      key :dev?, default: false
      key :https?, default: true
    end
  end
  let(:config) { klass.new }
  subject { config }
  describe '.key' do
    its(:hello) { is_expected.to eq 'world' }
    its(:dev?) { is_expected.to eq false }

    describe 'boolean assignment' do
      it { expect { subject.dev = 1 }.to raise_error ArgumentError }
      it { expect { subject.dev = true }.not_to raise_error }
      it { expect { subject.hello = 1 }.not_to raise_error }
      it { expect { subject.hello = true }.not_to raise_error }
      it { expect { subject.https = false }.to change { subject.https? }.to(false) }
    end
  end

  describe '#freeze' do
    before { config.freeze }
    it { is_expected.to be_frozen }
    it { expect { config.dev = true }.to raise_error RuntimeError }
  end
end
