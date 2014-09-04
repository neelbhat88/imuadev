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

      let(:orgId)      { subject.current_user.organization_id }
      let(:otherOrgId) { orgId + 1 }

      xit "returns 403 if an admin tries to create an Expectation for another Organization" do
        expectation = attributes_for(:expectation,
                                     organization_id: orgId)
        post :create_expectation, {:id => otherOrgId,
                                   :expectation => expectation}
        expect(response.status).to eq(403)
      end

      it "returns 200 if an admin tries to create an Expectation (json has different orgId)" do
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

      let(:orgId)      { subject.current_user.organization_id }
      let(:otherOrgId) { orgId + 1 }

      let!(:expectation)       { create(:expectation,
                                        organization_id: orgId) }
      let!(:other_expectation) { create(:expectation,
                                        organization_id: otherOrgId) }

      xit "returns 403 if an admin tries to update an Expectation for another Organization" do
        mod_expectation = attributes_for(:expectation,
                                         organization_id: expectation.organization_id,
                                         expectation_id: expectation.id)
        put :update_expectation, {:id => otherOrgId,
                                  :expectation_id => expectation.id,
                                  :expectation => mod_expectation}
        expect(response.status).to eq(403)
      end

      xit "returns 403 if an admin tries to update an Expectation under another Organization" do
        mod_expectation = attributes_for(:expectation,
                                         organization_id: other_expectation.organization_id,
                                         expectation_id: other_expectation.id)
        put :update_expectation, {:id => orgId,
                                  :expectation_id => other_expectation.id,
                                  :expectation => mod_expectation}
        expect(response.status).to eq(403)
      end

      it "returns 200 if an admin tries to update an Expectation (json has different orgId and expectation_id)" do
        mod_expectation = attributes_for(:expectation,
                                         organization_id: other_expectation.organization_id,
                                         expectation_id: other_expectation.id)
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

    describe "as a student" do
      login_student

      let(:orgId) { subject.current_user.organization_id }

      let!(:expectation) { create(:expectation,
                                  organization_id: orgId) }

      xit "returns 403 if a student tries to delete an Expectation" do
        delete :delete_expectation, {:id => orgId,
                                     :expectation_id => expectation.id}
        expect(response.status).to eq(403)
      end
    end

    describe "as an org admin" do
      login_org_admin

      let(:orgId)      { subject.current_user.organization_id }
      let(:otherOrgId) { orgId + 1 }

      let!(:expectation)       { create(:expectation,
                                        organization_id: orgId) }
      let!(:other_expectation) { create(:expectation,
                                        organization_id: otherOrgId) }

      xit "returns 403 if an admin tries to delete an Expectation for another Organization" do
        delete :delete_expectation, {:id => otherOrgId,
                                     :expectation_id => expectation.id}
        expect(response.status).to eq(403)
      end

      xit "returns 403 if an admin tries to delete an Expectation under another Organization" do
        delete :delete_expectation, {:id => orgId,
                                     :expectation_id => other_expectation.id}
        expect(response.status).to eq(403)
      end

      it "returns 200 if an admin tries to delete an Expectation" do
        delete :delete_expectation, {:id => orgId,
                                     :expectation_id => expectation.id}
        expect(response.status).to eq(200)
      end
    end

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

  describe "POST /users/:id/expectations/:expectation_id" do

    describe "as a student" do
      login_student

      let(:studentId) { subject.current_user.id }
      let(:orgId)     { subject.current_user.organization_id }

      let!(:expectation)      { create(:expectation,
                                       organization_id: orgId) }

      xit "returns 403 if a student tries to create a UserExpectation" do
        user_expectation = attributes_for(:user_expectation,
                                          expectation_id: expectation.id,
                                          user_id:        studentId)
        post :create_user_expectation, {:id => studentId,
                                        :expectation_id => expectation.id,
                                        :userExpectation => user_expectation}
        expect(response.status).to eq(403)
      end
    end

    describe "as an org admin" do
      login_org_admin

      let(:orgId)      { subject.current_user.organization_id }
      let(:otherOrgId) { orgId + 1 }

      let!(:student)       { create(:student,
                                    organization_id: orgId) }
      let!(:other_student) { create(:student,
                                    organization_id: otherOrgId) }

      let!(:expectation)       { create(:expectation,
                                        organization_id: orgId) }
      let!(:other_expectation) { create(:expectation,
                                        organization_id: otherOrgId) }

      xit "returns 403 if an admin tries to create a UserExpectation for an Expectation not in their Organization" do
        user_expectation = attributes_for(:user_expectation,
                                          expectation_id: expectation.id,
                                          user_id:        student.id)
        post :create_user_expectation, {:id => student.id,
                                        :expectation_id => other_expectation.id,
                                        :userExpectation => user_expectation}
        expect(response.status).to eq(403)
      end

      xit "returns 403 if an admin tries to create a UserExpectation for a User not in their Organization" do
        user_expectation = attributes_for(:user_expectation,
                                          expectation_id: expectation.id,
                                          user_id: student.id)
        post :create_user_expectation, {:id => other_student.id,
                                        :expectation_id => expectation.id,
                                        :userExpectation => user_expectation}
        expect(response.status).to eq(403)
      end

      it "returns 200 if an admin tries to create a UserExpectation (with incorrect json)" do
        user_expectation = attributes_for(:user_expectation,
                                          expectation_id: other_expectation.id,
                                          user_id:        other_student.id)
        post :create_user_expectation, {:id => student.id,
                                        :expectation_id => expectation.id,
                                        :userExpectation => user_expectation}

        expectation.to change(UserExpectationHistory, :count).by(1)
        expect(response.status).to eq(200)
        expect(json["user_expectation"]["expectation_id"]).to eq(expectation.id)
        expect(json["user_expectation"]["user_id"]).to eq(student.id)
      end
    end

  end

  describe "PUT /users/:id/expectations/:expectation_id" do

    describe "as a student" do
      login_student

      let(:studentId) { subject.current_user.id }
      let(:orgId)     { subject.current_user.organization_id }

      let!(:expectation)      { create(:expectation,
                                       organization_id: orgId) }
      let!(:user_expectation) { create(:user_expectation,
                                       expectation_id: expectation.id,
                                       user_id: studentId) }

      xit "returns 403 if a student tries to update a UserExpectation" do
        put :update_user_expectation, {:id => studentId,
                                       :expectation_id => expectation.id,
                                       :userExpectation => user_expectation}
        expect(response.status).to eq(403)
      end
    end

    describe "as an org admin" do
      login_org_admin

      let(:orgId)      { subject.current_user.organization_id }
      let(:otherOrgId) { orgId + 1 }

      let!(:student)       { create(:student,
                                    organization_id: orgId) }
      let!(:other_student) { create(:student,
                                    organization_id: otherOrgId) }

      let!(:expectation)       { create(:expectation,
                                        organization_id: orgId) }
      let!(:other_expectation) { create(:expectation,
                                        organization_id: otherOrgId) }

      let!(:user_expectation)       { create(:user_expectation,
                                             expectation_id: expectation.id,
                                             user_id: student.id) }
      let!(:other_user_expectation) { create(:user_expectation,
                                             expectation_id: other_expectation.id,
                                             user_id: other_student.id) }

      xit "returns 403 if an admin tries to update a UserExpectation for an Expectation not in their Organization" do
        user_expectation = attributes_for(:user_expectation,
                                          expectation_id: expectation.id,
                                          user_id:        student.id)
        put :update_user_expectation, {:id => student.id,
                                       :expectation_id => other_expectation.id,
                                       :userExpectation => user_expectation}
        expect(response.status).to eq(403)
      end

      xit "returns 403 if an admin tries to update a UserExpectation for a User not in their Organization" do
        user_expectation = attributes_for(:user_expectation,
                                          expectation_id: expectation.id,
                                          user_id: student.id)
        put :update_user_expectation, {:id => other_student.id,
                                       :expectation_id => expectation.id,
                                       :userExpectation => user_expectation}
        expect(response.status).to eq(403)
      end

      it "returns 200 if an admin tries to update a UserExpectation (with incorrect json)" do
        user_expectation = attributes_for(:user_expectation,
                                          expectation_id: other_expectation.id,
                                          user_id:        other_student.id)
        put :update_user_expectation, {:id => student.id,
                                       :expectation_id => expectation.id,
                                       :userExpectation => user_expectation}

        expectation.to change(UserExpectationHistory, :count).by(1)
        expect(response.status).to eq(200)
        expect(json["user_expectation"]["expectation_id"]).to eq(expectation.id)
        expect(json["user_expectation"]["user_id"]).to eq(student.id)
      end
    end

  end

  describe "DELETE /users/:id/expectations/:expectation_id" do

    describe "as a student" do
      login_student

      let(:studentId) { subject.current_user.id }
      let(:orgId)     { subject.current_user.organization_id }

      let!(:expectation)      { create(:expectation,
                                       organization_id: orgId) }
      let!(:user_expectation) { create(:user_expectation,
                                       expectation_id: expectation.id,
                                       user_id: studentId) }

      xit "returns 403 if a student tries to delete a UserExpectation" do
        delete :delete_user_expectation, {:id => studentId,
                                          :expectation_id => expectation.id}
        expect(response.status).to eq(403)
      end
    end

    describe "as an org admin" do
      login_org_admin

      let(:orgId)      { subject.current_user.organization_id }
      let(:otherOrgId) { orgId + 1 }

      let!(:student)       { create(:student,
                                    organization_id: orgId) }
      let!(:other_student) { create(:student,
                                    organization_id: otherOrgId) }

      let!(:expectation)       { create(:expectation,
                                        organization_id: orgId) }
      let!(:other_expectation) { create(:expectation,
                                        organization_id: otherOrgId) }

      let!(:user_expectation)       { create(:user_expectation,
                                             expectation_id: expectation.id,
                                             user_id: student.id) }
      let!(:other_user_expectation) { create(:user_expectation,
                                             expectation_id: other_expectation.id,
                                             user_id: other_student.id) }

      xit "returns 403 if an admin tries to delete a UserExpectation for an Expectation not in their Organization" do
        user_expectation = attributes_for(:user_expectation,
                                          expectation_id: expectation.id,
                                          user_id:        student.id)
        delete :delete_user_expectation, {:id => student.id,
                                          :expectation_id => other_expectation.id}
        expect(response.status).to eq(403)
      end

      xit "returns 403 if an admin tries to delete a UserExpectation for a User not in their Organization" do
        user_expectation = attributes_for(:user_expectation,
                                          expectation_id: expectation.id,
                                          user_id: student.id)
        delete :delete_user_expectation, {:id => other_student.id,
                                          :expectation_id => expectation.id,
                                          :userExpectation => user_expectation}
        expect(response.status).to eq(403)
      end

      it "returns 200 if an admin tries to delete a UserExpectation (with incorrect json)" do
        user_expectation = attributes_for(:user_expectation,
                                          expectation_id: other_expectation.id,
                                          user_id:        other_student.id)
        delete :delete_user_expectation, {:id => student.id,
                                          :expectation_id => expectation.id,
                                          :userExpectation => user_expectation}
        expect(response.status).to eq(200)
      end
    end

  end

end
