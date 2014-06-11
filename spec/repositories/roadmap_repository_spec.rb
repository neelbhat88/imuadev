require 'spec_helper'

describe RoadmapRepository do

  describe "#get_roadmap_by_organization" do
    xit "returns roadmap given valid orgId" do # x sets it to pending
      roadmap = Roadmap.new(:name => "Test")#instance_double("Roadmap", :name => "Test Roadmap", :organization_id => 1)

      # Roadmap.stub(:where) do | arg |
      #   if arg == 1
      #     roadmap
      #   else
      #     []
      #   end
      # end
      Roadmap.stub(:where).and_return(roadmap)

      RoadmapRepository.new.get_roadmap_by_organization(1).should == roadmap
      #RoadmapRepository.new.get_roadmap_by_organization(0).should eq(nil)
    end
  end

  describe "a stubbed implementation" do
  it "works" do
    object = Object.new
    object.stub(:foo) do |arg|
      if arg == :this
        "got this"
      elsif arg == :that
        "got that"
      end
    end

    object.foo(:this).should eq("got this")
    object.foo(:that).should eq("got that")
  end
end

end
