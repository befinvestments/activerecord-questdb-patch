require "active_record/connection_adapters/postgresql_adapter"
require_relative "arel/visitors/quest_db_sql"

# Provides monkey patch for ActiveRecord::ConnectionAdapters::PostgreSQLAdapter#arel_visitor
#
# Enabling minimal support for QuestDb SQL extensions
#
module QuestDbPatch
  module ArelVisitor
    private

    def arel_visitor
      Arel::Visitors::QuestDbSQL.new(self)
    end
  end
end

module ActiveRecord
  module ConnectionAdapters
    class PostgreSQLAdapter
      prepend QuestDbPatch::ArelVisitor
    end
  end
end
