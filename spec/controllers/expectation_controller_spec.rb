require 'rails_helper'

describe Api::V1::ExpectationController do

  #####################################
  ########### ORGANIZATION ############
  #####################################

  describe "GET /organization/:id/expectations" do

    describe "as a student" do
      login_student

      let(:studentId) { subject.current_user.id }
      let(:orgId)     { subject.current_user.organization_id }

      let!(:expectation) { create(:expectation,
                                  organization_id: orgId) }

      xit "returns 403 if a student tries to see another organizations's Expectations" do
        otherOrgId = orgId + 1
        get :get_expectations, {:id => otherOrgId}
        expect(response.status).to eq(403)
      end

      it "returns 200 if same organization" do
        get :get_expectations, {:id => orgId}
        expect(response.status).to eq(200)
        expect(json["expectations"][0]["organization_id"]).to eq(orgId)
      end

    end

  end

  describe "POST /organization/:id/expectations" do

    describe "as a student" do
      login_student

      let(:orgId) { subject.current_user.organization_id }

      xit "returns 403 if a student tries to create an Expectation" do
        expectation = attributes_for(:expectation,
                                     organization_id: orgId)
        post :create_expectation, {:id => orgId,
                                   :expectation => expectation}
        expect(response.status).to eq(403)
      end
    end

    describe "as an org admin" do
      login_org_admin

      let(:orgId) { subject.current_user.organization_id }
      let(:otherOrgId) { orgId + 1 }

      xit "returns 403 if an admin tries to create an Expectation for another Organization" do
        expectation = attributes_for(:expectation,
                                     organization_id: orgId)
        post :create_expectation, {:id => otherOrgId,
                                   :expectation => expectation}
        expect(response.status).to eq(403)
      end

      it "returns 200 if an admin tries to create an Expectation when json has different orgId" do
        mod_expectation = attributes_for(:expectation,
                                         organization_id: otherOrgId)
        post :create_expectation, {:id => orgId,
                                   :expectation => mod_expectation}
        expect(response.status).to eq(200)
        expect(json["expectation"]["organization_id"]).to eq(orgId)
      end
    end

  end

  describe "PUT /organization/:id/expectations/:expectation_id" do

    describe "as a student" do
      login_student

      let(:orgId) { subject.current_user.organization_id }

      let!(:expectation) { create(:expectation,
                                  organization_id: orgId) }

      xit "returns 403 if a student tries to update an Expectation" do
        put :update_expectation, {:id => orgId,
                                  :expectation_id => expectation.id,
                                  :expectation => expectation}
        expect(response.status).to eq(403)
      end
    end

    describe "as an org admin" do
      login_org_admin

      let(:orgId) { subject.current_user.organization_id }
      let(:otherOrgId) { orgId + 1 }

      let!(:expectation) { create(:expectation,
                                  organization_id: orgId) }
      let(:otherExpectationId) { expectation.id + 1}

      xit "returns 403 if an admin tries to update an Expectation for another Organization" do
        put :update_expectation, {:id => otherOrgId,
                                  :expectation_id => expectation.id,
                                  :expectation => expectation}
        expect(response.status).to eq(403)
      end

      it "returns 200 if an admin tries to update an Expectation when json has different orgId and expectation_id" do
        mod_expectation = attributes_for(:expectation,
                                         id: otherExpectationId,
                                         organization_id: otherOrgId)
        put :update_expectation, {:id => orgId,
                                  :expectation_id => expectation.id,
                                  :expectation => mod_expectation}
        expect(response.status).to eq(200)
        expect(json["expectation"]["id"]).to eq(expectation.id)
        expect(json["expectation"]["organization_id"]).to eq(orgId)
      end
    end

  end

  describe "DELETE /organization/:id/expectations/:expectation_id" do

  end

  #############################
  ########### USER ############
  #############################

  describe "GET /users/:id/expectations" do

    describe "as a student" do
      login_student

      let(:studentId) { subject.current_user.id }
      let(:orgId)     { subject.current_user.organization_id }

      let!(:expectation)      { create(:expectation,
                                       organization_id: orgId) }
      let!(:user_expectation) { create(:user_expectation,
                                       expectation_id: expectation.id,
                                       user_id:        studentId) }

      xit "returns 403 if a student tries to see another student's UserExpectations" do
        otherStudentId = studentId + 1
        get :get_user_expectations, {:id => otherStudentId}
        expect(response.status).to eq(403)
      end

      it "returns 200 if same student" do
        get :get_user_expectations, {:id => studentId}
        expect(response.status).to eq(200)
        expect(json["user_expectations"][0]["user_id"]).to eq(studentId)
        expect(json["user_expectations"][0]["expectation_id"]).to eq(expectation.id)
      end

    end

    describe "as a org admin" do
      login_org_admin

      let(:adminId) { subject.current_user.id }
      let(:orgId)   { subject.current_user.organization_id }

      let!(:expectation)      { create(:expectation,
                                       organization_id: orgId) }
      let!(:student)          { create(:student,
                                       organization_id: orgId) }
      let!(:user_expectation) { create(:user_expectation,
                                       expectation_id: expectation.id,
                                       user_id:        student.id) }

      xit "returns 403 if not in same organization" do
        otherOrgId = orgId + 1
        subject.current_user.organization_id = otherOrgId

        get :get_user_expectations, {:id => student.id}
        expect(response.status).to eq(403)
      end

      it "returns 200 if same organization" do
        get :get_user_expectations, {:id => student.id}
        expect(response.status).to eq(200)
        expect(json["user_expectations"][0]["user_id"]).to eq(student.id)
        expect(json["user_expectations"][0]["expectation_id"]).to eq(expectation.id)
      end
    end
  end

  describe "POST /users/:id/expectations" do

  end

  describe "PUT /users/:id/expectations/:expectation_id" do

  end

  describe "DELETE /users/:id/expectations/:expectation_id" do

  end

end
