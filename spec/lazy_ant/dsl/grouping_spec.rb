require 'spec_helper'

describe LazyAnt::DSL::Grouping do
  let(:klazz) do
    Class.new do
      include LazyAnt::DSL::Grouping

      group :hello do
        group :world
      end

      group :foo do
        group :bar
      end
    end
  end

  let(:client) { klazz.new }
  let(:connection) { double }
  describe 'hello' do
    subject { client.hello }
    it { is_expected.to be_a LazyAnt::Group }
    its(:name) { is_expected.to eq 'hello' }
  end

  describe 'hello.world' do
    subject { client.hello.world }
    it { is_expected.to be_a LazyAnt::Group }
    its(:name) { is_expected.to eq 'hello.world' }
  end
end
