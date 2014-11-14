require 'rails_helper'

describe Expectation do
  describe "is invalid" do
    it "without organization_id" do
      expect(Expectation.new(organization_id: nil)).to have(1).errors_on(:organization_id)
    end

    it "without title" do
      expect(Expectation.new(title: nil)).to have(1).errors_on(:title)
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
