require "active_record/connection_adapters/postgresql/schema_statements"

# Provides patch for PostgreSQL::SchemaStatements#quoted_scope
# https://github.com/rails/rails/blob/main/activerecord/lib/active_record/connection_adapters/postgresql/schema_statements.rb#L1088
#
# QuestDB's postgres implementation has the `current_schemas()` function
# but it does not implement the `ANY()` function. This patch replaces
# the `ANY (current_schemas(false))` SQL fragment with `current_schema()`
module QuestDbPatch
  module QuotedScope
    private

    def quoted_scope(name = nil, type: nil)
      scope = super(name, type:)
      scope[:schema] = "current_schema()" if pool.db_config.questdb?

      scope
    end
  end
end

module ActiveRecord
  module ConnectionAdapters
    module PostgreSQL
      module SchemaStatements
        prepend QuestDbPatch::QuotedScope
      end
    end
  end
end
