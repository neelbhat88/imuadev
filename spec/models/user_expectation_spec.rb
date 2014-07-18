require 'rails_helper'

describe UserExpectation do
  describe "is invalid" do
    it "without expectation_id" do
      expect(UserExpectation.new(expectation_id: nil)).to have(1).errors_on(:expectation_id)
    end

    it "without user_id" do
      expect(UserExpectation.new(user_id: nil)).to have(1).errors_on(:user_id)
    end

    it "without status" do
      expect(UserExpectation.new(status: nil)).to have(1).errors_on(:status)
    end

    it "if user_id, expectation_id already exists" do
      UserExpectation.create(expectation_id: 1,
                             user_id:        1,
                             status:         1)

      expect(UserExpectation.new(expectation_id: 1,
                                 user_id:        1,
                                 status:         1)).to have(1).errors_on(:expectation_id)
    end
  end
end
