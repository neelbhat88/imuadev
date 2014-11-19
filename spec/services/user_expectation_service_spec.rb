require 'rails_helper'

describe UserExpectationService do

  describe "create_user_expectation" do
    let(:current_user) { create(:org_admin) }

    before :each do
      @expectation = create(:expectation, title: "Expectation 1")
    end

    it "creates a user expectation with a corresponding history record" do
      ue = { :user_id => 1,
             :expectation_id => @expectation.id,
             :status => Constants.ExpectationStatus[:MEETING],
             :modified_by_name => User.SystemUser.first_name,
             :modified_by_id => User.SystemUser.id
           }
      user_expectation = UserExpectationService.new(current_user).create_user_expectation(ue)
      history = UserExpectationHistory.where(:user_expectation_id => user_expectation.id)

      expect(UserExpectation.where(:user_id => 1, :expectation_id => @expectation.id).length).to eq(1)
      expect(user_expectation.user_id).to eq(1)
      expect(user_expectation.expectation_id).to eq(@expectation.id)
      expect(user_expectation.status).to eq(Constants.ExpectationStatus[:MEETING])
      expect(user_expectation.modified_by_name).to eq(User.SystemUser.first_name)
      expect(user_expectation.modified_by_id).to eq(User.SystemUser.id)
      expect(user_expectation.comment).to be_nil

      expect(history.length).to eq(1)

      history = history[0]
      expect(history.user_expectation_id).to eq(user_expectation.id)
      expect(history.user_id).to eq(1)
      expect(history.expectation_id).to eq(@expectation.id)
      expect(history.status).to eq(Constants.ExpectationStatus[:MEETING])
      expect(history.modified_by_name).to eq(User.SystemUser.first_name)
      expect(history.modified_by_id).to eq(User.SystemUser.id)
      expect(history.comment).to be_nil
      expect(history.created_on).to_not be_nil
    end

    it "returns nil if any errors occurred while creating user expectation" do
      ue = { #This will fail since there is no user_id being passed in
             :expectation_id => @expectation.id,
             :status => Constants.ExpectationStatus[:MEETING],
             :modified_by_name => User.SystemUser.first_name,
             :modified_by_id => User.SystemUser.id
           }
      user_expectation = UserExpectationService.new(current_user).create_user_expectation(ue)
      history = UserExpectationHistory.all

      expect(user_expectation).to be_nil
      expect(history.length).to be(0)
    end
  end

  describe "create_user_expectations" do
    let(:current_user) { create(:org_admin) }

    before :each do
      @e1 = create(:expectation, title: "Expectation 1")
      @e2 = create(:expectation, title: "Expectation 2")
    end

    it "returns and does nothing if all user expectations already exist" do
      create(:user_expectation, expectation_id: @e1.id, user_id: current_user.id)
      create(:user_expectation, expectation_id: @e2.id, user_id: current_user.id)

      user_expectations = UserExpectationService.new(current_user).create_user_expectations(current_user.id)

      expect(user_expectations.length).to eq(2)
    end

    it "creates non-existing expectations with corresponding history entries" do
      existing_expectations = UserExpectation.where(:user_id => current_user.id)
      existing_history = UserExpectationHistory.where(:user_id => current_user.id)
      expect(existing_expectations.length).to eq(0)
      expect(existing_history.length).to eq(0)

      user_expectations = UserExpectationService.new(current_user).create_user_expectations(current_user.id)

      expect(user_expectations.length).to eq(2)
      expect(user_expectations[0].user_id).to eq(current_user.id)
      expect(user_expectations[0].expectation_id).to_not be_nil
      expect(user_expectations[0].status).to eq(Constants.ExpectationStatus[:MEETING])
      expect(user_expectations[0].modified_by_name).to eq("System")

      expectation_histories = UserExpectationHistory.where(:user_expectation_id => user_expectations.pluck(:id))
      expect(expectation_histories.length).to eq(2)
    end
  end

  describe "update user expectation" do
    let(:current_user) { create(:org_admin) }

    before :each do
      @expectation = create(:expectation, title: "Expectation 1")
    end

    it "updates the status, comment, modifier and logs history record" do
      dbUserExpectation = create(:user_expectation, expectation_id: @expectation.id)
      modifiedExpectation = {:status => Constants.ExpectationStatus[:NOT_MEETING], :comment => "Needs some more work"}

      user_expectation_obj = UserExpectationService.new(current_user).update_user_expectation(dbUserExpectation.id, modifiedExpectation)

      expect(user_expectation_obj.status).to eq(:ok)
      ue = user_expectation_obj.object
      expect(ue.status).to eq(Constants.ExpectationStatus[:NOT_MEETING])
      expect(ue.comment).to eq("Needs some more work")
      expect(ue.modified_by_id).to eq(current_user.id)
      expect(ue.modified_by_name).to eq(current_user.full_name)

      history = UserExpectationHistory.where(:user_expectation_id => ue.id)
      expect(history.length).to eq(1)
    end
  end

end
