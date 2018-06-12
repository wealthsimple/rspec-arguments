module RSpec
  module Arguments
    ARG_PREFIX = '__arg_'.freeze
    METHOD_ARG_PREFIX = '__m_arg_'.freeze

    POSITIONAL_ARG_SUFFIX = 'pos_'.freeze
    KEYWORD_ARG_SUFFIX = 'kw_'.freeze
    BLOCK_ARG_SUFFIX = 'blk_'.freeze

    POSITIONAL_ARG = ARG_PREFIX + POSITIONAL_ARG_SUFFIX
    KEYWORD_ARG = ARG_PREFIX + KEYWORD_ARG_SUFFIX
    BLOCK_ARG = ARG_PREFIX + BLOCK_ARG_SUFFIX

    METHOD_POSITIONAL_ARG = METHOD_ARG_PREFIX + POSITIONAL_ARG_SUFFIX
    METHOD_KEYWORD_ARG = METHOD_ARG_PREFIX + KEYWORD_ARG_SUFFIX
    METHOD_BLOCK_ARG = METHOD_ARG_PREFIX + BLOCK_ARG_SUFFIX

    def process_subject(clazz)
      class_method = method_under_test(:class_method)

      return call_method_with_args(clazz, class_method.to_sym) if class_method

      process_instance_subject
    end

    def process_instance_subject
      instance = self.instance

      method = method_under_test(:method)

      return instance unless method

      call_method_with_args(instance, method.to_sym)
    end

    def call_with_args(list, positional_arg, keyword_arg, block_arg, &proc)
      positional_args = []
      keyword_args = {}
      block_args = nil

      list.sort.each do |name|
        if name.to_s.start_with?(positional_arg)
          positional_args << send(name)
        elsif name.to_s.start_with?(keyword_arg)
          key = name[keyword_arg.size..-1].to_sym
          keyword_args[key] = send(name)
        elsif name.to_s.start_with?(block_arg)
          block_args = send(name)
        end
      end

      # DEBUG CODE
      # puts "positional_args #{positional_args}"
      # puts "keyword_args #{keyword_args}"
      # puts "block_arg #{block_args}"

      positional_args << keyword_args unless keyword_args.empty?

      proc.call(*positional_args, &block_args)
    end

    # Search for method under testing
    # inside ExampleGroupHash metadata
    #
    # TODO This can likely be improved by using
    # TODO RSpec filtered extensions.
    #
    def method_under_test(key)
      method_arg = self.class.metadata[key]

      return unless method_arg

      # Return here if you were nice and declared
      # your method under test using
      # `method: :method_name`.
      return method_arg if method_arg.is_a?(Symbol)

      # Otherwise, we have to search for the described
      # name string somewhere in our ancestor chain.

      # If we are inside a nested example group,
      # recursively search ascendants' metadata
      # for the correct method under testing.
      method_name = search_method_name(self.class.metadata, key)
      method_name.sub('#', '').sub('.', '').to_sym
    end

    def search_method_name(metadata, key)
      description = metadata[:description]

      return description if potential_method?(description)
      return description unless metadata[:parent_example_group] && metadata[:parent_example_group][key]

      search_method_name(metadata[:parent_example_group], key) if metadata[:parent_example_group]
    end

    def potential_method?(str)
      c = str[0]
      c == '#' || c == '.'
    end

    def call_initializer_with_args(receiver)
      call_with_args(
        self.class.instance_methods,
        POSITIONAL_ARG,
        KEYWORD_ARG,
        BLOCK_ARG,
      ) do |*args, &block|
        receiver.new(*args, &block)
      end
    end

    def call_method_with_args(receiver, method_sym)
      call_with_args(
        self.class.instance_methods,
        METHOD_POSITIONAL_ARG,
        METHOD_KEYWORD_ARG,
        METHOD_BLOCK_ARG,
      ) do |*args, &block|
        receiver.send(method_sym, *args, &block)
      end
    end
  end
end
