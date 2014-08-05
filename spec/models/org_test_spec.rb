require 'rails_helper'

describe OrgTest do
  describe "is invalid" do
    it "without organization_id" do
      expect(OrgTest.new(organization_id: nil)).to have(1).errors_on(:organization_id)
    end

    it "without title" do
      expect(OrgTest.new(title: nil)).to have(1).errors_on(:title)
    end

    it "without score_type" do
      expect(OrgTest.new(score_type: nil)).to have(1).errors_on(:score_type)
    end

    it "if organization_id, title already exists" do
      factory = create(:org_test)
      expect(OrgTest.new(organization_id: factory.organization_id,
                         title:           factory.title,
                         score_type:      factory.score_type,
                         description:     factory.description)).to have(1).errors_on(:title)
    end
  end
end
