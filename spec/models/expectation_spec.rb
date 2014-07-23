require 'rails_helper'

describe Expectation do
  describe "is invalid" do
    it "without organization_id" do
      expect(Expectation.new(organization_id: nil)).to have(1).errors_on(:organization_id)
    end

    it "without title" do
      expect(Expectation.new(title: nil)).to have(1).errors_on(:title)
    end

    it "without description" do
      expect(Expectation.new(description: nil)).to have(1).errors_on(:description)
    end

    it "without rank" do
      expect(Expectation.new(rank: nil)).to have(1).errors_on(:rank)
    end

    it "if organization_id, title already exists" do
      factory = create(:expectation)
      expect(Expectation.new(organization_id: factory.organization_id,
                             title:           factory.title,
                             description:     factory.description,
                             rank:            factory.rank)).to have(1).errors_on(:title)
    end
  end
end
