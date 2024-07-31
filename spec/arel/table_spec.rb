require "support/fake_record"
require 'questdb_patch/arel/table'

RSpec.describe QuestDbPatch::Arel::Table do
  let(:table) do
    Arel::Table
      .new(:users)
      .extend(QuestDbPatch::Arel::Table)
  end
  let(:projection) do
    table
      .project(Arel.star)
      .sample_by("10s")
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

  it "returns the expected SQL" do
    expect(projection.to_sql).to eq(%(SELECT * FROM "users" SAMPLE BY 10s))
  end
end
