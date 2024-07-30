require 'questdb_patch/arel/nodes/select_core'

RSpec.describe QuestDbPatch::Arel::Nodes::SelectCore do
  let(:core) { Arel::Nodes::SelectCore.new }

  describe "#sample_by=" do
    it "updates the instance variable" do
      expect { core.sample_by = "10s" }.to change(core, :sample_by).from(nil).to("10s")
    end
  end
end
