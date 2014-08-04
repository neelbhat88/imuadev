require 'rails_helper'

describe Api::V1::TestController do

  #####################################
  ########### ORGANIZATION ############
  #####################################

  describe "GET /organization/:id/tests" do

    describe "as a student" do
      login_student

      let(:orgId) { subject.current_user.organization_id }

      let!(:org)      { create(:organization, id: orgId) }
      let!(:otherOrg) { create(:organization, id: orgId + 1) }

      let!(:orgTest)      { create(:org_test, organization_id: org.id) }
      let!(:otherOrgTest) { create(:org_test, organization_id: otherOrg.id) }

      it "returns 403 if try to view another organization's tests" do
        get :get_org_tests, {:id => otherOrgTest.organization_id}
        expect(response.status).to eq(403)
      end

      it "returns 200 if same organization" do
        get :get_org_tests, {:id => orgTest.organization_id}
        expect(response.status).to eq(200)
        expect(json["orgTests"][0]["organization_id"]).to eq(orgId)
      end

    end

    describe "as a mentor" do
      login_mentor

      let(:orgId) { subject.current_user.organization_id }

      let!(:org)      { create(:organization, id: orgId) }
      let!(:otherOrg) { create(:organization, id: orgId + 1) }

      let!(:orgTest)      { create(:org_test, organization_id: org.id) }
      let!(:otherOrgTest) { create(:org_test, organization_id: otherOrg.id) }

      it "returns 403 if try to view another organization's tests" do
        get :get_org_tests, {:id => otherOrgTest.organization_id}
        expect(response.status).to eq(403)
      end

      it "returns 200 if same organization" do
        get :get_org_tests, {:id => orgTest.organization_id}
        expect(response.status).to eq(200)
        expect(json["orgTests"][0]["organization_id"]).to eq(orgId)
      end

    end

    describe "as an org admin" do
      login_org_admin

      let(:orgId) { subject.current_user.organization_id }

      let!(:org)      { create(:organization, id: orgId) }
      let!(:otherOrg) { create(:organization, id: orgId + 1) }

      let!(:orgTest)      { create(:org_test, organization_id: org.id) }
      let!(:otherOrgTest) { create(:org_test, organization_id: otherOrg.id) }

      it "returns 403 if try to view another organization's tests" do
        get :get_org_tests, {:id => otherOrgTest.organization_id}
        expect(response.status).to eq(403)
      end

      it "returns 200 if same organization" do
        get :get_org_tests, {:id => orgTest.organization_id}
        expect(response.status).to eq(200)
        expect(json["orgTests"][0]["organization_id"]).to eq(orgId)
      end

    end

    describe "as a super admin" do
      login_super_admin

      let!(:org)      { create(:organization, id: 1) }
      let!(:otherOrg) { create(:organization, id: 2) }

      let!(:orgTest)      { create(:org_test, organization_id: org.id) }
      let!(:otherOrgTest) { create(:org_test, organization_id: otherOrg.id) }

      it "returns 200 if super admin tries to view org1's tests" do
        get :get_org_tests, {:id => orgTest.organization_id}
        expect(response.status).to eq(200)
        expect(json["orgTests"][0]["organization_id"]).to eq(orgTest.organization_id)
      end

      it "returns 200 if super admin tries to view org2's tests" do
        get :get_org_tests, {:id => otherOrgTest.organization_id}
        expect(response.status).to eq(200)
        expect(json["orgTests"][0]["organization_id"]).to eq(otherOrgTest.organization_id)
      end

    end

  end

  describe "POST /org_test" do

    describe "as a student" do
      login_student

      let(:orgId) { subject.current_user.organization_id }
      let!(:org)  { create(:organization, id: orgId) }

      it "returns 403 if tries to create an organization test" do
        orgTest = attributes_for(:org_test, organization_id: org.id)
        post :create_org_test, {:orgTest => orgTest}
        expect(response.status).to eq(403)
      end
    end

    describe "as a mentor" do
      login_mentor

      let(:orgId) { subject.current_user.organization_id }
      let!(:org)  { create(:organization, id: orgId) }

      it "returns 403 if tries to create an organization test" do
        orgTest = attributes_for(:org_test, organization_id: org.id)
        post :create_org_test, {:orgTest => orgTest}
        expect(response.status).to eq(403)
      end
    end

    describe "as an org admin" do
      login_org_admin

      let(:orgId) { subject.current_user.organization_id }

      let!(:org)      { create(:organization, id: orgId) }
      let!(:otherOrg) { create(:organization, id: orgId + 1) }

      it "returns 403 if tries to create an organization test for a different organization" do
        otherOrgTest = attributes_for(:org_test, organization_id: otherOrg.id)
        post :create_org_test, {:orgTest => otherOrgTest}
        expect(response.status).to eq(403)
      end

      it "returns 200 if same organization" do
        orgTest = attributes_for(:org_test, organization_id: org.id)
        post :create_org_test, {:orgTest => orgTest}
        expect(response.status).to eq(200)
        expect(json["orgTest"]["organization_id"]).to eq(org.id)
      end
    end

    describe "as a super admin" do
      login_super_admin

      let!(:org1) { create(:organization, id: 1) }
      let!(:org2) { create(:organization, id: 2) }

      it "returns 200 if tries to create an organization test for org1" do
        org1Test = attributes_for(:org_test, organization_id: org1.id)
        post :create_org_test, {:orgTest => org1Test}
        expect(response.status).to eq(200)
        expect(json["orgTest"]["organization_id"]).to eq(org1.id)
      end

      it "returns 200 if tries to create an organization test for org2" do
        org2Test = attributes_for(:org_test, organization_id: org2.id)
        post :create_org_test, {:orgTest => org2Test}
        expect(response.status).to eq(200)
        expect(json["orgTest"]["organization_id"]).to eq(org2.id)
      end
    end

  end

  describe "PUT /org_test/:id" do

    describe "as a student" do
      login_student

      let(:orgId) { subject.current_user.organization_id }

      let!(:org)     { create(:organization, id: orgId) }
      let!(:orgTest) { create(:org_test, organization_id: org.id)}

      it "returns 403 if tries to update an organization test" do
        updatedOrgTest = attributes_for(:org_test, organization_id: org.id)
        put :update_org_test, {:id => orgTest.id, :orgTest => updatedOrgTest}
        expect(response.status).to eq(403)
      end
    end

    describe "as a mentor" do
      login_mentor

      let(:orgId) { subject.current_user.organization_id }

      let!(:org)     { create(:organization, id: orgId) }
      let!(:orgTest) { create(:org_test, organization_id: org.id)}

      it "returns 403 if tries to update an organization test" do
        updatedOrgTest = attributes_for(:org_test, organization_id: org.id)
        put :update_org_test, {:id => orgTest.id, :orgTest => updatedOrgTest}
        expect(response.status).to eq(403)
      end
    end

    describe "as an org admin" do
      login_org_admin

      let(:orgId) { subject.current_user.organization_id }

      let!(:org)      { create(:organization, id: orgId) }
      let!(:otherOrg) { create(:organization, id: orgId + 1) }

      let!(:orgTest)      { create(:org_test, organization_id: org.id)}
      let!(:otherOrgTest) { create(:org_test, organization_id: otherOrg.id)}

      it "returns 403 if tries to update an organization test for a different organization" do
        updatedOtherOrgTest = attributes_for(:org_test, organization_id: otherOrg.id)
        put :update_org_test, {:id => otherOrgTest.id, :orgTest => updatedOtherOrgTest}
        expect(response.status).to eq(403)
      end

      it "returns 200 if same organization" do
        updatedOrgTest = attributes_for(:org_test, organization_id: org.id)
        put :update_org_test, {:id => orgTest.id, :orgTest => updatedOrgTest}
        expect(response.status).to eq(200)
        expect(json["orgTest"]["id"]).to eq(orgTest.id)
      end
    end

    describe "as a super admin" do
      login_super_admin

      let!(:org1) { create(:organization, id: 1) }
      let!(:org2) { create(:organization, id: 2) }

      let!(:org1Test) { create(:org_test, organization_id: org1.id)}
      let!(:org2Test) { create(:org_test, organization_id: org2.id)}

      it "returns 200 if tries to update an organization test for org1" do
        updatedOrg1Test = attributes_for(:org_test, organization_id: org1.id)
        put :update_org_test, {:id => org1Test.id, :orgTest => updatedOrg1Test}
        expect(response.status).to eq(200)
        expect(json["orgTest"]["id"]).to eq(org1Test.id)
      end

      it "returns 200 if tries to update an organization test for org2" do
        updatedOrg2Test = attributes_for(:org_test, organization_id: org2.id)
        put :update_org_test, {:id => org2Test.id, :orgTest => updatedOrg2Test}
        expect(response.status).to eq(200)
        expect(json["orgTest"]["id"]).to eq(org2Test.id)
      end
    end

  end

  describe "DELETE /org_test/:id" do

    describe "as a student" do
      login_student

      let(:orgId) { subject.current_user.organization_id }

      let!(:org)     { create(:organization, id: orgId) }
      let!(:orgTest) { create(:org_test, organization_id: org.id)}

      it "returns 403 if tries to delete an organization test" do
        delete :delete_org_test, {:id => orgTest.id}
        expect(response.status).to eq(403)
      end
    end

    describe "as a mentor" do
      login_mentor

      let(:orgId) { subject.current_user.organization_id }

      let!(:org)     { create(:organization, id: orgId) }
      let!(:orgTest) { create(:org_test, organization_id: org.id)}

      it "returns 403 if tries to delete an organization test" do
        delete :delete_org_test, {:id => orgTest.id}
        expect(response.status).to eq(403)
      end
    end

    describe "as an org admin" do
      login_org_admin

      let(:orgId) { subject.current_user.organization_id }

      let!(:org)      { create(:organization, id: orgId) }
      let!(:otherOrg) { create(:organization, id: orgId + 1) }

      let!(:orgTest)      { create(:org_test, organization_id: org.id)}
      let!(:otherOrgTest) { create(:org_test, organization_id: otherOrg.id)}

      it "returns 403 if tries to delete an organization test for a different organization" do
        delete :delete_org_test, {:id => otherOrgTest.id}
        expect(response.status).to eq(403)
      end

      it "returns 200 if same organization" do
        delete :delete_org_test, {:id => orgTest.id}
        expect(response.status).to eq(200)
      end
    end

    describe "as a super admin" do
      login_super_admin

      let!(:org1) { create(:organization, id: 1) }
      let!(:org2) { create(:organization, id: 2) }

      let!(:org1Test) { create(:org_test, organization_id: org1.id)}
      let!(:org2Test) { create(:org_test, organization_id: org2.id)}

      it "returns 200 if tries to update an organization test for org1" do
        delete :delete_org_test, {:id => org1Test.id}
        expect(response.status).to eq(200)
      end

      it "returns 200 if tries to update an organization test for org2" do
        delete :delete_org_test, {:id => org2Test.id}
        expect(response.status).to eq(200)
      end
    end

  end

  #############################
  ########### USER ############
  #############################

  # describe "GET /users/:id/expectations" do
  #
  #   describe "as a student" do
  #     login_student
  #
  #     let(:studentId) { subject.current_user.id }
  #     let(:orgId)     { subject.current_user.organization_id }
  #
  #     let!(:expectation)      { create(:expectation,
  #                                      organization_id: orgId) }
  #     let!(:user_expectation) { create(:user_expectation,
  #                                      expectation_id: expectation.id,
  #                                      user_id:        studentId) }
  #
  #     xit "returns 403 if a student tries to see another student's UserExpectations" do
  #       otherStudentId = studentId + 1
  #       get :get_user_expectations, {:id => otherStudentId}
  #       expect(response.status).to eq(403)
  #     end
  #
  #     it "returns 200 if same student" do
  #       get :get_user_expectations, {:id => studentId}
  #       expect(response.status).to eq(200)
  #       expect(json["user_expectations"][0]["user_id"]).to eq(studentId)
  #       expect(json["user_expectations"][0]["expectation_id"]).to eq(expectation.id)
  #     end
  #
  #   end
  #
  #   describe "as a org admin" do
  #     login_org_admin
  #
  #     let(:adminId) { subject.current_user.id }
  #     let(:orgId)   { subject.current_user.organization_id }
  #
  #     let!(:expectation)      { create(:expectation,
  #                                      organization_id: orgId) }
  #     let!(:student)          { create(:student,
  #                                      organization_id: orgId) }
  #     let!(:user_expectation) { create(:user_expectation,
  #                                      expectation_id: expectation.id,
  #                                      user_id:        student.id) }
  #
  #     xit "returns 403 if not in same organization" do
  #       otherOrgId = orgId + 1
  #       subject.current_user.organization_id = otherOrgId
  #
  #       get :get_user_expectations, {:id => student.id}
  #       expect(response.status).to eq(403)
  #     end
  #
  #     it "returns 200 if same organization" do
  #       get :get_user_expectations, {:id => student.id}
  #       expect(response.status).to eq(200)
  #       expect(json["user_expectations"][0]["user_id"]).to eq(student.id)
  #       expect(json["user_expectations"][0]["expectation_id"]).to eq(expectation.id)
  #     end
  #   end
  # end
  #
  # describe "POST /users/:id/expectations/:expectation_id" do
  #
  #   describe "as a student" do
  #     login_student
  #
  #     let(:studentId) { subject.current_user.id }
  #     let(:orgId)     { subject.current_user.organization_id }
  #
  #     let!(:expectation)      { create(:expectation,
  #                                      organization_id: orgId) }
  #
  #     xit "returns 403 if a student tries to create a UserExpectation" do
  #       user_expectation = attributes_for(:user_expectation,
  #                                         expectation_id: expectation.id,
  #                                         user_id:        studentId)
  #       post :create_user_expectation, {:id => studentId,
  #                                       :expectation_id => expectation.id,
  #                                       :userExpectation => user_expectation}
  #       expect(response.status).to eq(403)
  #     end
  #   end
  #
  #   describe "as an org admin" do
  #     login_org_admin
  #
  #     let(:orgId)      { subject.current_user.organization_id }
  #     let(:otherOrgId) { orgId + 1 }
  #
  #     let!(:student)       { create(:student,
  #                                   organization_id: orgId) }
  #     let!(:other_student) { create(:student,
  #                                   organization_id: otherOrgId) }
  #
  #     let!(:expectation)       { create(:expectation,
  #                                       organization_id: orgId) }
  #     let!(:other_expectation) { create(:expectation,
  #                                       organization_id: otherOrgId) }
  #
  #     xit "returns 403 if an admin tries to create a UserExpectation for an Expectation not in their Organization" do
  #       user_expectation = attributes_for(:user_expectation,
  #                                         expectation_id: expectation.id,
  #                                         user_id:        student.id)
  #       post :create_user_expectation, {:id => student.id,
  #                                       :expectation_id => other_expectation.id,
  #                                       :userExpectation => user_expectation}
  #       expect(response.status).to eq(403)
  #     end
  #
  #     xit "returns 403 if an admin tries to create a UserExpectation for a User not in their Organization" do
  #       user_expectation = attributes_for(:user_expectation,
  #                                         expectation_id: expectation.id,
  #                                         user_id: student.id)
  #       post :create_user_expectation, {:id => other_student.id,
  #                                       :expectation_id => expectation.id,
  #                                       :userExpectation => user_expectation}
  #       expect(response.status).to eq(403)
  #     end
  #
  #     it "returns 200 if an admin tries to create a UserExpectation (with incorrect json)" do
  #       user_expectation = attributes_for(:user_expectation,
  #                                         expectation_id: other_expectation.id,
  #                                         user_id:        other_student.id)
  #       post :create_user_expectation, {:id => student.id,
  #                                       :expectation_id => expectation.id,
  #                                       :userExpectation => user_expectation}
  #       expect(response.status).to eq(200)
  #       expect(json["user_expectation"]["expectation_id"]).to eq(expectation.id)
  #       expect(json["user_expectation"]["user_id"]).to eq(student.id)
  #     end
  #   end
  #
  # end
  #
  # describe "PUT /users/:id/expectations/:expectation_id" do
  #
  #   describe "as a student" do
  #     login_student
  #
  #     let(:studentId) { subject.current_user.id }
  #     let(:orgId)     { subject.current_user.organization_id }
  #
  #     let!(:expectation)      { create(:expectation,
  #                                      organization_id: orgId) }
  #     let!(:user_expectation) { create(:user_expectation,
  #                                      expectation_id: expectation.id,
  #                                      user_id: studentId) }
  #
  #     xit "returns 403 if a student tries to update a UserExpectation" do
  #       put :update_user_expectation, {:id => studentId,
  #                                      :expectation_id => expectation.id,
  #                                      :userExpectation => user_expectation}
  #       expect(response.status).to eq(403)
  #     end
  #   end
  #
  #   describe "as an org admin" do
  #     login_org_admin
  #
  #     let(:orgId)      { subject.current_user.organization_id }
  #     let(:otherOrgId) { orgId + 1 }
  #
  #     let!(:student)       { create(:student,
  #                                   organization_id: orgId) }
  #     let!(:other_student) { create(:student,
  #                                   organization_id: otherOrgId) }
  #
  #     let!(:expectation)       { create(:expectation,
  #                                       organization_id: orgId) }
  #     let!(:other_expectation) { create(:expectation,
  #                                       organization_id: otherOrgId) }
  #
  #     let!(:user_expectation)       { create(:user_expectation,
  #                                            expectation_id: expectation.id,
  #                                            user_id: student.id) }
  #     let!(:other_user_expectation) { create(:user_expectation,
  #                                            expectation_id: other_expectation.id,
  #                                            user_id: other_student.id) }
  #
  #     xit "returns 403 if an admin tries to update a UserExpectation for an Expectation not in their Organization" do
  #       user_expectation = attributes_for(:user_expectation,
  #                                         expectation_id: expectation.id,
  #                                         user_id:        student.id)
  #       put :update_user_expectation, {:id => student.id,
  #                                      :expectation_id => other_expectation.id,
  #                                      :userExpectation => user_expectation}
  #       expect(response.status).to eq(403)
  #     end
  #
  #     xit "returns 403 if an admin tries to update a UserExpectation for a User not in their Organization" do
  #       user_expectation = attributes_for(:user_expectation,
  #                                         expectation_id: expectation.id,
  #                                         user_id: student.id)
  #       put :update_user_expectation, {:id => other_student.id,
  #                                      :expectation_id => expectation.id,
  #                                      :userExpectation => user_expectation}
  #       expect(response.status).to eq(403)
  #     end
  #
  #     it "returns 200 if an admin tries to update a UserExpectation (with incorrect json)" do
  #       user_expectation = attributes_for(:user_expectation,
  #                                         expectation_id: other_expectation.id,
  #                                         user_id:        other_student.id)
  #       put :update_user_expectation, {:id => student.id,
  #                                      :expectation_id => expectation.id,
  #                                      :userExpectation => user_expectation}
  #       expect(response.status).to eq(200)
  #       expect(json["user_expectation"]["expectation_id"]).to eq(expectation.id)
  #       expect(json["user_expectation"]["user_id"]).to eq(student.id)
  #     end
  #   end
  #
  # end
  #
  # describe "DELETE /users/:id/expectations/:expectation_id" do
  #
  #   describe "as a student" do
  #     login_student
  #
  #     let(:studentId) { subject.current_user.id }
  #     let(:orgId)     { subject.current_user.organization_id }
  #
  #     let!(:expectation)      { create(:expectation,
  #                                      organization_id: orgId) }
  #     let!(:user_expectation) { create(:user_expectation,
  #                                      expectation_id: expectation.id,
  #                                      user_id: studentId) }
  #
  #     xit "returns 403 if a student tries to delete a UserExpectation" do
  #       delete :delete_user_expectation, {:id => studentId,
  #                                         :expectation_id => expectation.id}
  #       expect(response.status).to eq(403)
  #     end
  #   end
  #
  #   describe "as an org admin" do
  #     login_org_admin
  #
  #     let(:orgId)      { subject.current_user.organization_id }
  #     let(:otherOrgId) { orgId + 1 }
  #
  #     let!(:student)       { create(:student,
  #                                   organization_id: orgId) }
  #     let!(:other_student) { create(:student,
  #                                   organization_id: otherOrgId) }
  #
  #     let!(:expectation)       { create(:expectation,
  #                                       organization_id: orgId) }
  #     let!(:other_expectation) { create(:expectation,
  #                                       organization_id: otherOrgId) }
  #
  #     let!(:user_expectation)       { create(:user_expectation,
  #                                            expectation_id: expectation.id,
  #                                            user_id: student.id) }
  #     let!(:other_user_expectation) { create(:user_expectation,
  #                                            expectation_id: other_expectation.id,
  #                                            user_id: other_student.id) }
  #
  #     xit "returns 403 if an admin tries to delete a UserExpectation for an Expectation not in their Organization" do
  #       user_expectation = attributes_for(:user_expectation,
  #                                         expectation_id: expectation.id,
  #                                         user_id:        student.id)
  #       delete :delete_user_expectation, {:id => student.id,
  #                                         :expectation_id => other_expectation.id}
  #       expect(response.status).to eq(403)
  #     end
  #
  #     xit "returns 403 if an admin tries to delete a UserExpectation for a User not in their Organization" do
  #       user_expectation = attributes_for(:user_expectation,
  #                                         expectation_id: expectation.id,
  #                                         user_id: student.id)
  #       delete :delete_user_expectation, {:id => other_student.id,
  #                                         :expectation_id => expectation.id,
  #                                         :userExpectation => user_expectation}
  #       expect(response.status).to eq(403)
  #     end
  #
  #     it "returns 200 if an admin tries to delete a UserExpectation (with incorrect json)" do
  #       user_expectation = attributes_for(:user_expectation,
  #                                         expectation_id: other_expectation.id,
  #                                         user_id:        other_student.id)
  #       delete :delete_user_expectation, {:id => student.id,
  #                                         :expectation_id => expectation.id,
  #                                         :userExpectation => user_expectation}
  #       expect(response.status).to eq(200)
  #     end
  #   end
  #
  # end

end
