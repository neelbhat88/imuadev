require 'rails_helper'

describe UserTest do
  describe "is invalid" do
    it "without org_test_id" do
      expect(UserTest.new(org_test_id: nil)).to have(1).errors_on(:org_test_id)
    end

    it "without user_id" do
      expect(UserTest.new(user_id: nil)).to have(1).errors_on(:user_id)
    end

    it "without time_unit_id" do
      expect(UserTest.new(time_unit_id: nil)).to have(1).errors_on(:time_unit_id)
    end

    it "without date" do
      expect(UserTest.new(date: nil)).to have(1).errors_on(:date)
    end
  end
end
