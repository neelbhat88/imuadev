require 'rails_helper'

describe UserMilestone do
  describe "is invalid" do
    it "without milestone_id" do
      expect(UserMilestone.new(milestone_id: nil)).to have(1).errors_on(:milestone_id)
    end

    it "without module" do
      expect(UserMilestone.new(module: nil)).to have(1).errors_on(:module)
    end

    it "without submodule" do
      expect(UserMilestone.new(submodule: nil)).to have(1).errors_on(:submodule)
    end

    it "without user_id" do
      expect(UserMilestone.new(user_id: nil)).to have(1).errors_on(:user_id)
    end

    it "without time_unit_id" do
      expect(UserMilestone.new(time_unit_id: nil)).to have(1).errors_on(:time_unit_id)
    end

    it "if user already earned milestone in a time_unit" do
      UserMilestone.create(milestone_id: 1, user_id: 1, time_unit_id: 1, module: "module", submodule: "submodule")

      expect(UserMilestone.new(
                milestone_id: 1,
                user_id: 1,
                time_unit_id: 1,
                module: "module",
                submodule: "submodule")
      ).to have(1).errors_on(:milestone_id)
    end
  end

end
