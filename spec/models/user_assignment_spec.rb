require 'rails_helper'

describe UserAssignment do
  describe "is invalid" do
    it "without expectation_id" do
      expect(UserAssignment.new(assignment_id: nil)).to have(1).errors_on(:assignment_id)
    end

    it "without user_id" do
      expect(UserAssignment.new(user_id: nil)).to have(1).errors_on(:user_id)
    end

    it "without status" do
      expect(UserAssignment.new(status: nil)).to have(1).errors_on(:status)
    end

    it "if user_id, assignment_id already exists" do
      factory = create(:user_assignment)
      expect(UserAssignment.new(assignment_id: factory.assignment_id,
                                 user_id:      factory.user_id,
                                 status:       factory.status)).to have(1).errors_on(:assignment_id)
    end
  end
end
