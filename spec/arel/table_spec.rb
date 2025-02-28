require "support/fake_record"
require 'questdb_patch/arel/table'

RSpec.describe QuestDbPatch::Arel::Table do
  let(:table) do
    Arel::Table
      .new(:users)
      .extend(QuestDbPatch::Arel::Table)
  end

  before do
    @arel_engine = Arel::Table.engine
    Arel::Table.engine = FakeRecord::Base.new(
      visitor_klass: QuestDbPatch::Arel::Visitors::QuestDbSQL
    )
  end

  after do
    Arel::Table.engine = @arel_engine if defined? @arel_engine
  end

  describe ".sample_by" do
    let(:projection) do
      table
        .project(Arel.star)
        .sample_by("10s")
    end

    it "returns the expected SQL" do
      expect(projection.to_sql).to eq(%(SELECT * FROM "users" SAMPLE BY 10s))
    end
  end

  describe ".fill" do
    let(:projection) do
      table
        .project(Arel.star)
        .sample_by(*parameters)
    end

    context "when passed a valid keyword" do
      let(:parameters) { ["10s FILL(PREV)"] }

      it "returns the expected SQL" do
        expect(projection.to_sql).to eq(%(SELECT * FROM "users" SAMPLE BY 10s FILL(PREV)))
      end
    end
  end
end
