require "arel/nodes/select_core"

module QuestDbPatch
  module Arel
    module Nodes
      # Extension for Arel::Nodes::SelectCore class
      # to provide minimal support for QuestDb's SAMPLE BY SQL extension
      module SelectCore
        attr_accessor :sample_by

        def initialize(*)
          super
          @sample_by = nil
        end

        def initialize_copy(other)
          super
          @sample_by = @sample_by.clone
        end

        def hash
          instance_variables
            .map { |name| instance_variable_get(name) }
            .push(@sample_by)
            .hash
        end

        def eql?(other)
          super && sample_by == other.sample_by
        end
      end
    end
  end
end
