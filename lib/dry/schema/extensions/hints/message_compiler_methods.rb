# frozen_string_literal: true

module Dry
  module Schema
    module Extensions
      module Hints
        module MessageCompilerMethods
          HINT_TYPE_EXCLUSION = %i[
            key? nil? bool? str? int? float? decimal?
            date? date_time? time? hash? array?
          ].freeze

          HINT_OTHER_EXCLUSION = %i[format? filled?].freeze

          attr_reader :hints

          def initialize(*args)
            super
            @hints = @options.fetch(:hints, true)
          end

          # @api private
          def hints?
            hints.equal?(true)
          end

          # @api private
          def filter(messages, opts)
            Array(messages).flatten.map { |msg| msg unless exclude?(msg, opts) }.compact.uniq
          end

          # @api private
          def exclude?(messages, opts)
            Array(messages).all? do |msg|
              hints = opts.hints.reject { |hint| msg == hint }.reject { |hint| hint.predicate == :filled? }
              key_failure = opts.key_failure?(msg.path)
              predicate = msg.predicate

              (HINT_TYPE_EXCLUSION.include?(predicate) && !key_failure) ||
                (msg.predicate == :filled? && key_failure) ||
                  (!key_failure && HINT_TYPE_EXCLUSION.include?(predicate) && !hints.empty? && hints.any? { |hint| hint.path == msg.path }) ||
                    HINT_OTHER_EXCLUSION.include?(predicate)
            end
          end

          # @api private
          def message_type(options)
            options[:message_type].equal?(:hint) ? Hint : Message
          end

          # @api private
          def visit_hint(node, opts)
            if hints?
              filter(visit(node, opts.(message_type: :hint)), opts)
            end
          end

          # @api private
          def visit_predicate(node, opts)
            message = super
            opts.current_messages << message
            message
          end

          # @api private
          def visit_each(node, opts)
            # TODO: we can still generate a hint for elements here!
            []
          end
        end
      end
    end
  end
end
