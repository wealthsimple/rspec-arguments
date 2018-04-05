module RSpec
  module Arguments
    module MonkeyPatcher
      include RSpec::Arguments

      #
      # The only 🐵-patching in this gem.
      #
      # Mostly untouched, except we call
      # `process_subject`, instead of simply
      # instantiating the described_class.
      #
      def subject
        __memoized.fetch_or_store(:subject) do
          described = described_class || self.class.metadata.fetch(:description_args).first
          Class === described ? process_subject(described) : described
        end
      end
    end
  end
end
