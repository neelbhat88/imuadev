require 'rails_helper'

describe UserExpectation do
  describe "abilities" do
    subject(:ability){ Ability.new(user) }
    let(:user){ nil }

    context "students" do
      let(:user){ build(:student) }

      it "can only view expectations" do
        should be_able_to(:view, UserExpectation.new)
        should_not be_able_to(:create, UserExpectation.new)
        should_not be_able_to(:update, UserExpectation.new)
        should_not be_able_to(:destroy, UserExpectation.new)
        should_not be_able_to(:manage, UserExpectation.new)
      end

    end
  end

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
      factory = create(:user_expectation)
      expect(UserExpectation.new(expectation_id: factory.expectation_id,
                                 user_id:        factory.user_id,
                                 status:         factory.status)).to have(1).errors_on(:expectation_id)
    end
  end
end
