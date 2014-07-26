require 'rails_helper'

describe Milestone do
  describe "is invalid" do
    it "without title" do
      expect(Milestone.new(title: nil)).to have(1).errors_on(:title)
    end

    it "without description" do
      expect(Milestone.new(description: nil)).to have(1).errors_on(:description)
    end

    it "without value" do
      expect(Milestone.new(value: nil)).to have(1).errors_on(:value)
    end

    it "without module" do
      expect(Milestone.new(module: nil)).to have(1).errors_on(:module)
    end

    it "without submodule" do
      expect(Milestone.new(submodule: nil)).to have(1).errors_on(:submodule)
    end

    it "without importance" do
      expect(Milestone.new(importance: nil)).to have(1).errors_on(:importance)
    end

    it "without points" do
      expect(Milestone.new(points: nil)).to have(1).errors_on(:points)
    end

    it "without time_unit_id" do
      expect(Milestone.new(time_unit_id: nil)).to have(1).errors_on(:time_unit_id)
    end

    it "without icon" do
      expect(Milestone.new(icon: nil)).to have(1).errors_on(:icon)
    end

    it "without organization_id" do
      expect(Milestone.new(organization_id: nil)).to have(1).errors_on(:organization_id)
    end

  end

end
