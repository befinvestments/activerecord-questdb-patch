require_relative "nodes/sample_by"
require_relative "nodes/select_core"

module QuestDbPatch
  module Arel
    module SelectManager
      def sample_by(value)
        if value
          @ctx.sample_by = ::Arel::Nodes::SampleBy.new(value)
        else
          @ctx.sample_by = nil
        end
        self
      end
    end
  end
end
