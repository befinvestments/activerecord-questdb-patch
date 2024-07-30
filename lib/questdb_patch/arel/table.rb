require_relative "select_manager"

module QuestDbPatch
  module Arel
    module Table
      def from
        super.extend(QuestDbPatch::Arel::SelectManager)
      end
    end
  end
end
