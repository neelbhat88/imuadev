require 'rails_helper'

describe Relationship do
  describe "is invalid" do
    it "without user_id" do
      expect(Relationship.new(user_id: nil)).to have(1).errors_on(:user_id)
    end

    it "without assigned_to_id" do
      expect(Relationship.new(assigned_to_id: nil)).to have(1).errors_on(:assigned_to_id)
    end

    it "if user_id, assigned_to_id already exists" do
      create(:relationship, user_id: 1, assigned_to_id: 1)

      expect(Relationship.new(user_id: 1, assigned_to_id: 1)).to have(1).errors_on(:assigned_to_id)
    end
  end
end
