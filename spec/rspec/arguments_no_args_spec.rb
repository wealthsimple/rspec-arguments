class NoArgs
  def perform
    1
  end

  def self.class_perform
    2
  end
end

RSpec.describe NoArgs, :untouched do
  it 'test should remain unchanged' do
    expect(RSpec::Arguments).to receive(:process_subject).never
    subject
  end
end

RSpec.describe NoArgs do
  context '#perform', :method do
    it { is_expected.to eq(1) }
  end

  context 'class_perform', :class_method do
    it { is_expected.to eq(2) }
  end
end
