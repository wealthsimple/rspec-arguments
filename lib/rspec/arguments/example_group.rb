module RSpec
  module Arguments
    module ExampleGroup
      #
      # @param name [Symbol] binds this parameter to the named method `name`,
      #   implemented by calling `let(name)`.
      # @param position [Integer,Symbol] if an Integer is provided, binds this
      #   argument to a the positional argument at position `position`, 0 indexed.
      #   If Symbol is provided, binds thi argument to the keyword argument `position`.
      # @param block [Proc] value to be used for this argument
      #
      # @example
      #
      #   describe Thing do
      #     arg(:first, 0) { '0' }
      #     arg(:second, 1) { '1' }
      #     arg(:kw_arg) { 3 }
      #     arg_block(:blk) { proc { 'body' } }
      #
      #     # `subject` is now: Thing.new('0', '1', kw_arg: 3, &blk)
      #
      #     it { is_expect(subject).to be_a(Thing) }
      #     it { is_expect(subject.perform).to be_nil }
      #   end
      #
      # TODO support anonymous positional: arg(0) { '0' }
      #
      def arg(name, position = nil, &block)
        _arg(POSITIONAL_ARG, KEYWORD_ARG, name, position, &block)
      end

      #
      # Similar to `arg(name, position, &block)`,
      # but binds this argument as the &block argument
      # provided to the instance initializer.
      #
      def arg_block(name = '', &block)
        _arg_block(BLOCK_ARG, name, &block)
      end

      #
      # Similar to `arg(name, position, &block)`,
      # but binds this argument to the described method,
      # instead of described class.
      #
      def method_arg(name, position = nil, &block)
        _arg(METHOD_POSITIONAL_ARG, METHOD_KEYWORD_ARG, name, position, &block)
      end

      #
      # Similar to `arg_block(name, &block)`,
      # but binds this argument to the described method,
      # instead of described class.
      #
      def method_arg_block(name = '', &block)
        _arg_block(METHOD_BLOCK_ARG, name, &block)
      end

      def instance(name = nil, &block)
        if name
          let(name, &block)
          alias_method :instance, name

          self::NamedSubjectPreventSuper.__send__(:define_method, name) do
            raise NotImplementedError, "`super` in named instances is not supported"
          end
        else
          let(:instance, &block)
        end
      end

      def instance!(name = nil, &block)
        instance(name, &block)
        before { instance }
      end

      private

      def _arg(positional_arg, keyword_arg, name, position = nil, &block)
        metadata[:rspec_arguments] = true

        let(name, &block)

        if position.is_a?(Integer)
          let(positional_arg.+(position.to_s).to_sym) { send(name) }
        else
          let(keyword_arg.+((position || name).to_s).to_sym) { send(name) }
        end
      end

      def _arg_block(block_arg, name, &block)
        metadata[:rspec_arguments] = true

        let(name, &block)

        let(block_arg.+(name.to_s).to_sym) { send(name) }
      end
    end
  end
end
