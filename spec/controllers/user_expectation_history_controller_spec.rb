require 'rails_helper'

describe Api::V1::UserExpectationHistoryController do

  describe "GET /users/:user_id/user_expectation_history?expectation_id=#" do

    describe "as a mentor" do
      login_mentor

      let(:mentorId) { subject.current_user.id }

      let!(:expectationHistory) { create(:user_expectation_history, modified_by_id: mentorId) }

      it "returns 200 for mentor" do
        get :get_user_expectation_history, {:id => expectationHistory.user_id,
                                            :expectation_id => expectationHistory.expectation_id}
        expect(response.status).to eq(200)
        expect(json["expectation_history"][0]["modified_by_id"]).to eq(mentorId)
      end

    end

    describe "as a org admin" do
      login_org_admin

      let(:orgAdminId) { subject.current_user.id }

      let!(:expectationHistory) { create(:user_expectation_history, modified_by_id: orgAdminId) }

      it "returns 200 for org admin" do
        get :get_user_expectation_history, {:id => expectationHistory.user_id,
                                            :expectation_id => expectationHistory.expectation_id}
        expect(response.status).to eq(200)
        expect(json["expectation_history"][0]["modified_by_id"]).to eq(orgAdminId)
      end

    end

  end

end
