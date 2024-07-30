[![build&deploy](https://github.com/befinvestments/activerecord-questdb-patch/actions/workflows/ruby.yml/badge.svg)](https://github.com/befinvestments/activerecord-questdb-patch/actions/workflows/ruby.yml)

# ActiveRecord QuestDB Patch

Provides patches for [ActiveRecord::ConnectionAdapters::PostgreSQLAdapter](https://github.com/rails/rails/tree/main/activerecord/lib/active_record/connection_adapters)
enabling read-only access to QuestDb via the Postgresql wire protocol

Provided as is without any guarantees in the hope that it might be useful.

## Compatibility

Tested wth:

    ActiveRecord 7.1.3
    QuestDB 7.4.2
    Ruby 3.2

## Installation

Add it to your Gemfile:

    gem "activerecord-questdb-patch", git: "https://github.com/befinvestments/activerecord-questdb-patch.git"

## Configuration:

Once installed you can add a `questdb: true` parameter to your database.yml configuration
which will cause the patches to be applied to that connection.

## Example configuration block:

```
    questdb:
      questdb: true
      database_tasks: false
      adapter:  postgresql
      encoding: unicode
      host:     <%= ENV.fetch("QUESTDB_HOST", "localhost") %>
      port:     <%= ENV.fetch("QUESTDB_PORT", 8812) %>
      username: <%= ENV.fetch("QUESTDB_USER", nil) %>
      password: <%= ENV.fetch("QUESTDB_PASSWORD", nil) %>
      pool:     <%= ENV.fetch("RAILS_MAX_THREADS") { 5 } %>
```

## Minimal support for QuestDb's SAMPLE BY SQL extension vial Arel helpers

Example usage:

```
    require "questdb_patch/arel/table"
    # Base class for ActiveRecord models that connect to QuestDb
    class QuestDbBase < ApplicationRecord
      self.abstract_class = true

      connects_to database: { writing: :questdb, reading: :questdb }

      def self.arel_table
        @arel_table ||= super.extend(QuestDbPatch::Arel::Table)
      end
    end
```

Then:

```
    MyClass < QuestDbBase; end

    MyClass
        .arel_table
        .project(Arel.star)
        .sample_by("10s")
```

`FILL`, `ALIGN TO`, and `FROM`, `TO` keywords are NOT currently supported.

## License

See the LICENSE file for licensing information.
