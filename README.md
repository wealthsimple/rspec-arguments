# RSpec Arguments [![CircleCI](https://circleci.com/gh/wealthsimple/rspec-arguments.svg?style=svg)](https://circleci.com/gh/wealthsimple/rspec-arguments) [![Gem](https://img.shields.io/gem/v/rspec-arguments.svg)](https://rubygems.org/gems/rspec-arguments)

Provide arguments to the implicit RSpec `subject`.
Also, call instance and class methods implicitly.

## Example (TL;DR)

```ruby
class Thing
  def initializer(username)
  end
  
  def perform(save:)
    save
  end
end

RSpec.describe Thing do
  arg(:username, 0) { 'user123' }

  it { is_expected.to be_a(Thing) }

  describe '#save', :method do
    method_arg(:save) { true }
    
    it { is_expected.to eq(save) }
  end
end
```

## Documentation

Out-of-the box, RSpec provides us with an implicit `subject` method that instantiates the described class under test, giving us an instance which we can assert on:

```ruby
class User
end

RSpec.describe User do
  it { is_expected.to be_a(User) }
do
```

This is very terse and works great for classes with no initialization parameters.

But we can't use the implicit `subject` when initialization parameters need to be provided.

```ruby
class User
  def initialize(name, tag:)
    # ...
  end
end

RSpec.describe User do
  let(:name) { 'Eva' }
  let(:tag) { :mobile }
  
  subject { described_class.new(name, tag: tag) }

  it { is_expected.to be_a(User) }
do
```

Now you have to explicitly declare your `subject`, proving the required parameters to the initializer.

Having parameters in initializers is not uncommon.
This gem provides new methods that allow you to implicitly provide initializer arguments to the implicit `subject`:

```ruby
RSpec.describe User do
  arg(:name, 0) { 'Eva' }
  arg(:tag) { :mobile }
  
  # Translates to:
  # subject { described_class.new(name, tag: tag) }

  it { is_expected.to be_a(User) }
end
```

In this example, `:name` is an initializer positional argument, at position `0`, and `:tag` is the keyword argument with the same symbol.

The interesting part happens when we want to call a method from the class instance under test, a very common use case.

To illustrate this, let's add a new method `save` to the class `User`:

```ruby
class User
  def initialize(name, tag:)
    # ...
  end
  
  def save(validate, touch)
    # ...
    return validate
  end
end
```

Traditionally, we could test it as such:

```ruby
RSpec.describe User do
  arg(:name, 0) { 'Eva' }
  arg(:tag) { :mobile }

  it { is_expected.to be_a(User) }

  describe '#save' do
    let(:validate) { false }
    let(:touch) { true }
    
    subject { described_class.new(name, tag: tag).save(validate, touch) }
    
    it { is_expected.to eq(validate) }
  end
end
```

Notice we can't reuse our implicit `subject`, and have to resort to re-initializing our `described_class`, and proving the required arguments to the desired method.

Similarly to initializer methods, this gem introduces methods to facilitate implicit method calls.

```ruby
RSpec.describe User do
  arg(:name, 0) { 'Eva' }
  arg(:tag) { :mobile }

  it { is_expected.to be_a(User) }

  describe '#save', :method do
    method_arg(:validate, 0) { false }
    method_arg(:touch, 1) { true }
    
    # Translates to:
    # subject { described_class.new(name, tag: tag).save(validate, touch) }
    
    it { is_expected.to eq(validate) }
  end
end
```

Notice that we don't have to repeat ourselves on what method needs to be tested, `save` in this case, as we can infer it from the `describe '#method_name', :method do` context.

Lastly, here's a full example, including methods requiring `&block` arguments, and class method calls:

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
