require 'helper'

describe Gocdkit::Client::PipelineGroups do

  before do
    VCR.turn_on!
  end

  describe ".pipeline_groups", :vcr do
      it "returns all pipeline groups on the server" do
        pipeline_groups = Gocdkit.client.pipeline_groups
        expect(pipeline_groups.first[:name]).to match(/defaultGroup/)
      end
  end # .pipeline_groups

end
