require 'spec_helper'

describe LazyAnt::Group do
  let(:klazz) do
    Class.new described_class do
      self.name = :a
    end
  end
  let(:other_klazz) do
    Class.new described_class do
      self.name = :b
    end
  end
  let(:group) { klazz.new }
  it { expect(group.name).to eq 'a' }
  it { expect(other_klazz.name).to eq 'b' }
end
