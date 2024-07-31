require "support/fake_record"
require "questdb_patch/arel/nodes/sample_by"
require "questdb_patch/arel/nodes/select_core"
require "questdb_patch/arel/visitors/quest_db_sql"

RSpec.describe QuestDbPatch::Arel::Visitors::QuestDbSQL do
  let(:engine)    { FakeRecord::Base.new(visitor_klass: described_class) }
  let(:visitor)   { described_class.new(engine.lease_connection) }
  let(:collector) { Arel::Collectors::SQLString.new }

  describe "#accept" do
    context "when given an Arel::Nodes::SelectCore" do
      let(:node) { ::Arel::Nodes::SelectCore.new }

      it "returns the expected value" do
        expect(visitor.accept(node, collector).value).to eq("SELECT")
      end
    end

    context "when given an extended Arel::Nodes::SelectCore" do
      let(:node) { ::Arel::Nodes::SelectCore.include(QuestDbPatch::Arel::Nodes::SelectCore).new }

      before { node.sample_by = ::Arel::Nodes::SampleBy.new("10s") }

      it "returns the expected value" do
        expect(visitor.accept(node, collector).value).to eq("SELECT SAMPLE BY 10s")
      end
    end
  end
end

RSpec.describe ::Arel::Visitors::PostgreSQL do
  let(:engine)    { FakeRecord::Base.new(visitor_klass: described_class) }
  let(:visitor)   { described_class.new(engine.lease_connection) }
  let(:collector) { Arel::Collectors::SQLString.new }

  describe "#accept" do
    context "when given an Arel::Nodes::SelectCore" do
      let(:node) { ::Arel::Nodes::SelectCore.new }

      it "returns the expected value" do
        expect(visitor.accept(node, collector).value).to eq("SELECT")
      end
    end

    context "when given an extended Arel::Nodes::SelectCore" do
      let(:node) { ::Arel::Nodes::SelectCore.include(QuestDbPatch::Arel::Nodes::SelectCore).new }

      before { node.sample_by = ::Arel::Nodes::SampleBy.new("10s") }

      it "returns the expected value" do
        expect(visitor.accept(node, collector).value).to eq("SELECT")
      end
    end
  end
end
