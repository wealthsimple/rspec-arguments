module RSpec
  module Arguments
    module MonkeyPatcher
      include RSpec::Arguments

      #
      # The only monkey-patching in this gem.
      #
      # Mostly untouched, except we call
      # `process_subject`, instead of simply
      # instantiating the described_class.
      #
      def subject
        __memoized.fetch_or_store(:subject) do
          metadata = self.class.metadata
          described = described_class || metadata.fetch(:description_args).first

          if described.is_a?(Class)
            if metadata[:rspec_arguments] || metadata[:method] || metadata[:class_method]
              process_subject(described) { |instance| __memoized.fetch_or_store(:instance) { instance } }
            else
              described.new
            end
          else
            described
          end
        end
      end

      #
      # Reference to the instantiated object, if testing an instance or instance method (but not class method).
      #
      def instance
        subject # Ensures subject has been loaded
        __memoized.fetch_or_store(:instance) { raise 'Instance is only available when testing class instances or instance methods' }
      end
    end
  end
end
