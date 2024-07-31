require "support/fake_record"
require 'questdb_patch/arel/select_manager'

RSpec.describe QuestDbPatch::Arel::SelectManager do
  let(:manager) do
    Arel::Table.new(:users).from.extend(QuestDbPatch::Arel::SelectManager)
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

  describe "#sample_by" do
    let(:projection) do
      manager
        .project(Arel.star)
        .sample_by(sample_arg)
    end

    context "with an argument" do
      let(:sample_arg) { "10s" }

      it "returns the expected SQL" do
        expect(projection.to_sql).to eq('SELECT * FROM "users" SAMPLE BY 10s')
      end
    end

    context "when passing nil" do
      let(:sample_arg) { nil }

      it "returns the expected SQL" do
        expect(projection.to_sql).to eq('SELECT * FROM "users"')
      end
    end
  end
end
