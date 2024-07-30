require "arel/nodes/unary"

module Arel
  module Nodes
    # Provides minimal support for QuestDb SAMPLE BY extension
    # FILL, ALIGN TO, and FROM, TO keywords are NOT supported.
    # https://questdb.io/docs/reference/sql/sample-by/
    class SampleBy < ::Arel::Nodes::Unary
    end
  end
end
