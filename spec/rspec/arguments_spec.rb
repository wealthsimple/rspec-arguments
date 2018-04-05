class C
  attr_accessor :arg
  attr_accessor :kwarg
  attr_accessor :block

  def initialize(arg, kwarg:, &block)
    @arg = arg
    @kwarg = kwarg
    @block = block
  end

  def instance_method(arg, kwarg:, &block)
    C.new(arg, kwarg: kwarg, &block)
  end

  def wrong_method(*)
    :wrong_method
  end

  def self.class_method(arg, kwarg:, &block)
    new(arg, kwarg: kwarg, &block)
  end
end

shared_examples :simple_args do
  its(:arg) { is_expected.to eq(arg) }
  its(:kwarg) { is_expected.to eq(:kw_value) }
  its(:block) { is_expected.to eq(block) }
end

shared_examples :simple_method_args do
  its(:arg) { is_expected.to eq(m_arg) }
  its(:kwarg) { is_expected.to eq(:m_kw_value) }
  its(:block) { is_expected.to eq(m_block) }
end

RSpec.describe C do
  arg(:arg, 0) { :arg_0 }
  arg(:kwarg) { :kw_value }
  arg_block(:block) { proc {} }

  context 'simple' do
    it_behaves_like :simple_args
  end

  context 'with partial override' do
    let(:arg) { :other }

    it_behaves_like :simple_args
  end

  context 'with complete override' do
    arg(:arg, 0) { :other }

    it_behaves_like :simple_args

    its(:arg) { is_expected.to eq(:other) }
  end

  describe 'with method arguments' do
    method_arg(:m_arg, 0) { :m_arg_0 }
    method_arg(:m_kwarg, :kwarg) { :m_kw_value }
    method_arg_block(:m_block) { proc {} }

    # method_arg(0) { :m_arg_0 }
    # method_arg(:kwarg) { :m_kw_value }

    context '#instance_method', :method do
      it_behaves_like :simple_method_args
    end

    context '.class_method', :class_method do
      it_behaves_like :simple_method_args
    end

    context '#wrong_method', :method do
      it { is_expected.to eq(:wrong_method)}
    end
  end
end
