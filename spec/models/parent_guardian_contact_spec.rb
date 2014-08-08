require 'rails_helper'

describe ParentGuardianContact do
  describe "is invalid" do
    it "without user_id" do
      expect(ParentGuardianContact.new(user_id: nil)).to have(1).errors_on(:user_id)
    end

    it "without name" do
      expect(ParentGuardianContact.new(name: nil)).to have(1).errors_on(:name)
    end

    it "without relationship" do
      expect(ParentGuardianContact.new(relationship: nil)).to have(1).errors_on(:relationship)
    end

    it "without phone" do
      expect(ParentGuardianContact.new(phone: nil)).to have(1).errors_on(:phone)
    end
  end
end
