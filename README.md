# RSpec Arguments [![CircleCI](https://circleci.com/gh/wealthsimple/rspec-arguments.svg?style=svg)](https://circleci.com/gh/wealthsimple/rspec-arguments)

http://blog.davidchelimsky.net/blog/2012/05/13/spec-smell-explicit-use-of-subject/

TL;DR

Explicit use of the “subject” abstraction is a code smell, and should be refactored to use a more intention revealing name whenever possible.

## Example

```ruby
class User
  def initialize(name, tag:)
    # ...
  end
  
  def save(validate, touch)
    # ...
    return validate
  end
  
  def self.find_all(&block)
    # ...
    block.call
  end
end
```

```ruby
RSpec.describe User do
  let(:name) { 'Eva' }
  let(:tag) { :mobile }

  subject { described_class.new(name, tag: tag) }

  it { is_expected.to be_a(User) }

  describe '#save' do
    let(:validate) { false }
    let(:touch) { true }
    
    subject { described_class.new(name, tag: tag).save(validate, touch) }
    
    it { is_expected.to eq(validate) }
  end
  
  context '.find_all' do
    let(:block) { proc { 1 } }
    
    subject { described_class.find_all(&block) }

    it { is_expected.to eq(1) }
  end
end
```

```ruby
RSpec.describe User do
  arg(:name, 0) { 'Eva' }
  arg(:tag) { :mobile }

  it { is_expected.to be_a(User) }

  describe '#save', :method do
    method_arg(:validate, 0) { false }
    method_arg(:touch, 1) { true }
    
    it { is_expected.to eq(validate) }
  end
  
  context '.find_all', :class_method do
    method_arg_block(:block) { proc { 1 } }

    it { is_expected.to eq(1) }
  end
end
```
