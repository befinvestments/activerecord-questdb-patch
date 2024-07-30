require 'questdb_patch'

RSpec.describe QuestDbPatch do
  let(:connection) do
    ActiveRecord::ConnectionAdapters::PostgreSQLAdapter.new(
      QuestDbPatch::FakeConnection.new, ActiveRecord::Base.logger,
      nil, { host: File::NULL }
    )
  end
  let(:table_name) { "a_db_table" }

  describe "#arel_visitor" do
    it "returns the expected instance type" do
      expect(connection.send(:arel_visitor)).to be_a(QuestDbPatch::Arel::Visitors::QuestDbSQL)
    end
  end

  describe "#column_definitions" do
    before do
      allow(connection).to receive(:query)
      allow(connection.pool.db_config).to receive(:questdb?).and_return(db_config)

      connection.send(:column_definitions, table_name)
    end

    context "when db is not a QuestDB" do
      let(:db_config) { false }
      let(:expected_sql) do
        <<~SQL.squish
          SELECT a.attname, format_type(a.atttypid, a.atttypmod),
            pg_get_expr(d.adbin, d.adrelid), a.attnotnull, a.atttypid, a.atttypmod,
            c.collname, col_description(a.attrelid, a.attnum) AS comment,
            attidentity AS identity,
            attgenerated as attgenerated
            FROM pg_attribute a
            LEFT JOIN pg_attrdef d ON a.attrelid = d.adrelid AND a.attnum = d.adnum
            LEFT JOIN pg_type t ON a.atttypid = t.oid
            LEFT JOIN pg_collation c ON a.attcollation = c.oid AND a.attcollation <> t.typcollation
            WHERE a.attrelid = '"#{table_name}"'::regclass
            AND a.attnum > 0 AND NOT a.attisdropped
            ORDER BY a.attnum
        SQL
      end

      it "verifies questdb? configuration" do
        expect(connection.pool.db_config).to have_received(:questdb?)
      end

      it "calls query with the expected SQL" do
        expect(connection).to have_received(:query).with(ignore_whitespace(expected_sql), "SCHEMA")
      end
    end

    context "when db is a QuestDB" do
      let(:db_config) { true }
      let(:expected_sql) do
        <<~SQL.squish
          SELECT a.attname,
            s."type" AS "format_type",
            pg_get_expr(d.adbin, d.adrelid),
            a.attnotnull,
            a.atttypid,
            a.atttypmod,
            '' as collname,
            '' AS comment,
            attidentity AS identity,
            attgenerated as attgenerated
            FROM pg_attribute a
            LEFT JOIN pg_attrdef d ON a.attrelid = d.adrelid AND a.attnum = d.adnum
            LEFT JOIN pg_type t ON a.atttypid = t.oid
            JOIN pg_class pgc ON pgc.oid = a.attrelid
            LEFT JOIN table_columns('#{table_name}') s ON a.attname = s."column"
            WHERE pgc.relname = '#{table_name}'
              AND a.attnum > 0 AND NOT a.attisdropped
            ORDER BY a.attnum
        SQL
      end

      it "verifies questdb? configuration" do
        expect(connection.pool.db_config).to have_received(:questdb?)
      end

      it "calls query with the expected SQL" do
        expect(connection).to have_received(:query).with(expected_sql, "SCHEMA")
      end
    end
  end

  describe "#quoted_scope" do
    before do
      allow(connection.pool.db_config).to receive(:questdb?).and_return(db_config)
      connection.send(:quoted_scope)
    end

    context "when db is not a QuestDB" do
      let(:db_config)    { false }
      let(:quoted_scope) { { schema: "ANY (current_schemas(false))" } }

      it "verifies questdb? configuration" do
        expect(connection.pool.db_config).to have_received(:questdb?)
      end

      it "returns the expected value" do
        expect(connection.send(:quoted_scope)).to eq(quoted_scope)
      end
    end

    context "when db is a QuestDB" do
      let(:db_config)    { true }
      let(:quoted_scope) { { schema: "current_schema()" } }

      it "verifies questdb? configuration" do
        expect(connection.pool.db_config).to have_received(:questdb?)
      end

      it "returns the expected value" do
        expect(connection.send(:quoted_scope)).to eq(quoted_scope)
      end
    end
  end
end
