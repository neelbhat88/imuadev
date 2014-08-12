require 'rails_helper'

describe Api::V1::MilestoneController do

  describe 'POST :create_milestone' do
    login_org_admin

    it "returns 200 and adds milestone to database" do
      expect {
        post :create_milestone, milestone: attributes_for(:milestone)
      }.to change(Milestone, :count).by(1)

      expect(response.status).to eq(200)
      expect(json["milestone"]).to_not be_nil
    end

    it "sets organization_id of milestone to current_user's organization_id" do
      subject.current_user.organization_id = 12345

      post :create_milestone, milestone: attributes_for(:milestone)

      id = json["milestone"]["id"].to_i
      milestone = Milestone.find(id)

      expect(milestone.organization_id).to eq(12345)
    end

    it "sets all properties on return object correctly" do
      milestone = build(:gpa_milestone, points: 20, value: "4.0")

      post :create_milestone, milestone: milestone.attributes

      jsonMilestone = json["milestone"]
      expect(jsonMilestone["id"]).to_not be_nil
      expect(jsonMilestone["value"]).to eq(milestone.value)
      expect(jsonMilestone["title"]).to eq("Good Grades")
      expect(jsonMilestone["description"]).to eq("Minimum GPA:")
      expect(jsonMilestone["icon"]).to eq("/assets/Academics.jpg")
    end

    it "sets time_unit_id in database correctly" do
      milestone = build(:gpa_milestone, points: 20, value: "4.0")

      post :create_milestone, milestone: milestone.attributes

      id = json["milestone"]["id"].to_i
      dbmilestone = Milestone.find(id)

      expect(dbmilestone.time_unit_id).to eq(milestone.time_unit_id)
    end

  end

end
