require "arel/visitors/postgresql"

module QuestDbPatch
  module Arel # :nodoc: all
    module Visitors
      class QuestDbSQL < ::Arel::Visitors::PostgreSQL
        private

        def visit_Arel_Nodes_SelectCore(o, collector)
          super
          maybe_visit o.sample_by, collector
        end

        def visit_Arel_Nodes_SampleBy(o, collector)
          collector << "SAMPLE BY " << o.expr
        end
      end
    end
  end
end
