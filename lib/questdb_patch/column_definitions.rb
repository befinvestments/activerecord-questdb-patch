require "active_record/connection_adapters/postgresql_adapter"

# Provides monkey patch for ActiveRecord::ConnectionAdapters::PostgreSQLAdapter#column_definitions
#
# https://github.com/rails/rails/blob/main/activerecord/lib/active_record/connection_adapters/postgresql_adapter.rb#L1068-L1083
#
# QuestDB's postgresql wire protocol implementation is missing support for the following
# postgresql functions that are used in the column_defintions query SQL statement
#
# * pg_collation table:       ERROR:  table does not exist [table=pg_collation]
# * ::regclass function:      ERROR:  unsupported class [name="one_sec_sensors"]
# * col_description function: ERROR:  unknown function name: col_description(INT,SHORT)
#
# the postgresql format_type function is used by ActiveRecord to determine type casts and while
# the function exists in the QuestDb postgresql implementation, it currently returns an
# empty string rather than the expected type identifier:
#
# https://github.com/questdb/questdb/blob/389fb8ea836efc0fc19cd95c6284f68b20f752c2/core/src/main/java/io/questdb/griffin/engine/functions/catalogue/FormatTypeFunctionFactory.java#L43
#
# As a workaround this monkey patch uses the QuestDb table_columns metadata function to
# retrieve type information for the columns. The type information provided doesn't match
# what would is provided by a  postgresql server, however it appears to be sufficient for
# ActiveRecord # to perform basic type casts. This functionality has not been tested
# extensively so there may be some QuestDb types that are not handled correctly.
module QuestDbPatch
  module ColumnDefinitions
    private

    def column_definitions(table_name)
      return super unless pool.db_config.questdb?

      query(_quest_db_column_definitions_sql(table_name), "SCHEMA")
    end

    def _quest_db_column_definitions_sql(table_name)
      <<~SQL.squish
        SELECT
          a.attname,
          s."type" AS "format_type",
          pg_get_expr(d.adbin, d.adrelid),
          a.attnotnull,
          a.atttypid,
          a.atttypmod,
          '' as collname,
          '' AS comment,
           #{supports_identity_columns? ? 'attidentity' : quote('')} AS identity,
           #{supports_virtual_columns? ? 'attgenerated' : quote('')} as attgenerated
        FROM pg_attribute a
        LEFT JOIN pg_attrdef d ON a.attrelid = d.adrelid AND a.attnum = d.adnum
        LEFT JOIN pg_type t ON a.atttypid = t.oid
        JOIN pg_class pgc ON pgc.oid = a.attrelid
        LEFT JOIN table_columns('#{table_name}') s ON a.attname = s."column"
        WHERE pgc.relname = '#{table_name}' AND a.attnum > 0 AND NOT a.attisdropped
        ORDER BY a.attnum
      SQL
    end
  end
end

module ActiveRecord
  module ConnectionAdapters
    class PostgreSQLAdapter
      prepend QuestDbPatch::ColumnDefinitions
    end
  end
end
