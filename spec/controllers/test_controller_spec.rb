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

  describe "GET /users/:id/tests?time_unit_id=#" do

    describe "as a student" do
      login_student

      let(:userId)     { subject.current_user.id }
      let(:orgId)      { subject.current_user.organization_id }
      let(:timeUnitId) { subject.current_user.time_unit_id }

      let!(:org)          { create(:organization, id: orgId) }
      let!(:otherStudent) { create(:student, organization_id: org.id) }
      let(:otherUserId)   { otherStudent.id }

      let!(:orgTest)      { create(:org_test, organization_id: org.id) }

      let!(:userTest1)    { create(:user_test, org_test_id: orgTest.id,
                                               user_id: userId,
                                               time_unit_id: timeUnitId) }
      let!(:userTest2)    { create(:user_test, org_test_id: orgTest.id,
                                               user_id: userId,
                                               time_unit_id: timeUnitId + 1) }

      let!(:otherUserTest1) { create(:user_test, org_test_id: orgTest.id,
                                                 user_id: otherUserId,
                                                 time_unit_id: timeUnitId) }
      let!(:otherUserTest2) { create(:user_test, org_test_id: orgTest.id,
                                                 user_id: otherUserId,
                                                 time_unit_id: timeUnitId + 1) }

      it "returns 403 if try to view another student's tests (all)" do
        get :get_user_tests, {:id => otherUserId}
        expect(response.status).to eq(403)
      end

      it "returns 403 if try to view another student's tests (for a particular time unit)" do
        get :get_user_tests, {:id => otherUserId, :time_unit_id => timeUnitId}
        expect(response.status).to eq(403)
      end

      it "returns 200 if own tests (all)" do
        get :get_user_tests, {:id => userId}
        expect(response.status).to eq(200)
        expect(json["userTests"][0]["id"]).to eq(userTest1.id)
        expect(json["userTests"][1]["id"]).to eq(userTest2.id)
      end

      it "returns 200 if own tests (for a particular time unit)" do
        get :get_user_tests, {:id => userId, :time_unit_id => timeUnitId}
        expect(response.status).to eq(200)
        expect(json["userTests"][0]["id"]).to eq(userTest1.id)
        expect(json["userTests"][1]).to eq(nil)
      end
    end

    describe "as a mentor" do
      login_mentor

      let(:userId)     { subject.current_user.id }
      let(:orgId)      { subject.current_user.organization_id }
      let!(:org)       { create(:organization, id: orgId) }
      let(:timeUnitId) { 1 }

      let!(:student1) { create(:student, organization_id: org.id) }
      let!(:student2) { create(:student, organization_id: org.id) }

      let!(:relationship) { create(:relationship, user_id: student1.id,
                                                  assigned_to_id: userId) }

      let!(:orgTest) { create(:org_test, organization_id: org.id) }

      let!(:student1Test1) { create(:user_test, org_test_id: orgTest.id,
                                                user_id: student1.id,
                                                time_unit_id: timeUnitId) }
      let!(:student1Test2) { create(:user_test, org_test_id: orgTest.id,
                                                user_id: student1.id,
                                                time_unit_id: timeUnitId + 1) }

      let!(:student2Test1) { create(:user_test, org_test_id: orgTest.id,
                                                 user_id: student2.id,
                                                 time_unit_id: timeUnitId) }
      let!(:student2Test2) { create(:user_test, org_test_id: orgTest.id,
                                                 user_id: student2.id,
                                                 time_unit_id: timeUnitId + 1) }

      it "returns 403 if try to view a student's tests (all) who is not assigned to them." do
        get :get_user_tests, {:id => student2.id}
        expect(response.status).to eq(403)
      end

      it "returns 403 if try to view a student's tests (for a particular time unit) who is not assigned to them." do
        get :get_user_tests, {:id => student2.id, :time_unit_id => timeUnitId}
        expect(response.status).to eq(403)
      end

      it "returns 200 if try to view a student's tests (all) who is assigned to them." do
        get :get_user_tests, {:id => student1.id}
        expect(response.status).to eq(200)
        expect(json["userTests"][0]["id"]).to eq(student1Test1.id)
        expect(json["userTests"][1]["id"]).to eq(student1Test2.id)
      end

      it "returns 200 if try to view a student's tests (for a particular time unit) who is assigned to them." do
        get :get_user_tests, {:id => student1.id, :time_unit_id => timeUnitId}
        expect(response.status).to eq(200)
        expect(json["userTests"][0]["id"]).to eq(student1Test1.id)
        expect(json["userTests"][1]).to eq(nil)
      end
    end

    describe "as an org admin" do
      login_org_admin

      let(:timeUnitId) { 1 }

      let(:orgId) { subject.current_user.organization_id }
      let!(:org)  { create(:organization, id: orgId) }

      let!(:student1) { create(:student, organization_id: org.id) }
      let!(:orgTest)  { create(:org_test, organization_id: org.id) }

      let!(:student1Test1) { create(:user_test, org_test_id: orgTest.id,
                                                user_id: student1.id,
                                                time_unit_id: timeUnitId) }
      let!(:student1Test2) { create(:user_test, org_test_id: orgTest.id,
                                                user_id: student1.id,
                                                time_unit_id: timeUnitId + 1) }

      let(:otherOrgId) { orgId + 1 }
      let!(:otherOrg)  { create(:organization, id: otherOrgId) }

      let!(:student2)      { create(:student, organization_id: otherOrg.id) }
      let!(:otherOrgTest)  { create(:org_test, organization_id: otherOrg.id) }

      let!(:student2Test1) { create(:user_test, org_test_id: otherOrgTest.id,
                                                user_id: student2.id,
                                                time_unit_id: timeUnitId) }
      let!(:student2Test2) { create(:user_test, org_test_id: otherOrgTest.id,
                                                user_id: student2.id,
                                                time_unit_id: timeUnitId + 1) }

      it "returns 403 if try to view a student's tests (all) for different organization." do
        get :get_user_tests, {:id => student2.id}
        expect(response.status).to eq(403)
      end

      it "returns 403 if try to view a student's tests (for a particular time unit) for different organization." do
        get :get_user_tests, {:id => student2.id, :time_unit_id => timeUnitId}
        expect(response.status).to eq(403)
      end

      it "returns 200 if try to view a student's tests (all) within same organization." do
        get :get_user_tests, {:id => student1.id}
        expect(response.status).to eq(200)
        expect(json["userTests"][0]["id"]).to eq(student1Test1.id)
        expect(json["userTests"][1]["id"]).to eq(student1Test2.id)
      end

      it "returns 200 if try to view a student's tests (for a particular time unit) within same organization." do
        get :get_user_tests, {:id => student1.id, :time_unit_id => timeUnitId}
        expect(response.status).to eq(200)
        expect(json["userTests"][0]["id"]).to eq(student1Test1.id)
        expect(json["userTests"][1]).to eq(nil)
      end
    end

    describe "as a super admin" do
      login_super_admin

      let(:timeUnitId) { 1 }

      let(:orgId) { 1 }
      let!(:org)  { create(:organization, id: orgId) }

      let!(:student1) { create(:student, organization_id: org.id) }
      let!(:orgTest)  { create(:org_test, organization_id: org.id) }

      let!(:student1Test1) { create(:user_test, org_test_id: orgTest.id,
                                                user_id: student1.id,
                                                time_unit_id: timeUnitId) }
      let!(:student1Test2) { create(:user_test, org_test_id: orgTest.id,
                                                user_id: student1.id,
                                                time_unit_id: timeUnitId + 1) }

      let(:otherOrgId) { orgId + 1 }
      let!(:otherOrg)  { create(:organization, id: otherOrgId) }

      let!(:student2)      { create(:student, organization_id: otherOrg.id) }
      let!(:otherOrgTest)  { create(:org_test, organization_id: otherOrg.id) }

      let!(:student2Test1) { create(:user_test, org_test_id: otherOrgTest.id,
                                                user_id: student2.id,
                                                time_unit_id: timeUnitId) }
      let!(:student2Test2) { create(:user_test, org_test_id: otherOrgTest.id,
                                                user_id: student2.id,
                                                time_unit_id: timeUnitId + 1) }

      it "returns 200 if try to view a student1's tests (all)." do
        get :get_user_tests, {:id => student1.id}
        expect(response.status).to eq(200)
        expect(json["userTests"][0]["id"]).to eq(student1Test1.id)
        expect(json["userTests"][1]["id"]).to eq(student1Test2.id)
      end

      it "returns 200 if try to view a student1's tests (for a particular time unit)." do
        get :get_user_tests, {:id => student1.id, :time_unit_id => timeUnitId}
        expect(response.status).to eq(200)
        expect(json["userTests"][0]["id"]).to eq(student1Test1.id)
        expect(json["userTests"][1]).to eq(nil)
      end

      it "returns 200 if try to view a student2's tests (all)." do
        get :get_user_tests, {:id => student2.id}
        expect(response.status).to eq(200)
        expect(json["userTests"][0]["id"]).to eq(student2Test1.id)
        expect(json["userTests"][1]["id"]).to eq(student2Test2.id)
      end

      it "returns 200 if try to view a student2's tests (for a particular time unit)." do
        get :get_user_tests, {:id => student2.id, :time_unit_id => timeUnitId}
        expect(response.status).to eq(200)
        expect(json["userTests"][0]["id"]).to eq(student2Test1.id)
        expect(json["userTests"][1]).to eq(nil)
      end
    end

  end

  describe "POST /user_test" do

    describe "as a student" do
      login_student

      let(:userId)     { subject.current_user.id }
      let(:orgId)      { subject.current_user.organization_id }
      let(:timeUnitId) { subject.current_user.time_unit_id }

      let!(:org)        { create(:organization, id: orgId) }
      let!(:otherUser)  { create(:student, organization_id: org.id) }
      let!(:orgTest)    { create(:org_test, organization_id: org.id) }

      it "returns 403 if creating a test for another student" do
        otherUserTest = attributes_for(:user_test, org_test_id: orgTest.id,
                                                   user_id: otherUser.id)
        post :create_user_test, {:userTest => otherUserTest}
        expect(response.status).to eq(403)
      end

      it "returns 200 if creating a test for themself" do
        userTest = attributes_for(:user_test, org_test_id: orgTest.id,
                                              user_id: userId)
        post :create_user_test, {:userTest => userTest}
        expect(response.status).to eq(200)
        expect(json["userTest"]["user_id"]).to eq(userId)
      end

      # TODO More tests like this across the entire suite
      xit "returns 403 if creating a test for themself for a time_unit other than the one that they're currently in." do
        userTest = attributes_for(:user_test, org_test_id: orgTest.id,
                                              user_id: userId,
                                              time_unit_id: timeUnitId + 1)
        post :create_user_test, {:userTest => userTest}
        expect(response.status).to eq(403)
      end
    end

    describe "as a mentor" do
      login_mentor

      let(:userId) { subject.current_user.id }
      let(:orgId)  { subject.current_user.organization_id }
      let!(:org)   { create(:organization, id: orgId) }

      let!(:student1) { create(:student, organization_id: org.id) }
      let!(:student2) { create(:student, organization_id: org.id) }

      let!(:relationship) { create(:relationship, user_id: student1.id,
                                                  assigned_to_id: userId) }

      let!(:orgTest)    { create(:org_test, organization_id: org.id) }

      it "returns 403 if creating a test for a student not assigned to them" do
        userTest = attributes_for(:user_test, org_test_id: orgTest.id,
                                              user_id: student2.id)
        post :create_user_test, {:userTest => userTest}
        expect(response.status).to eq(403)
      end

      it "returns 200 if creating a test for a student assigned to them" do
        userTest = attributes_for(:user_test, org_test_id: orgTest.id,
                                              user_id: student1.id)
        post :create_user_test, {:userTest => userTest}
        expect(response.status).to eq(200)
        expect(json["userTest"]["user_id"]).to eq(student1.id)
      end
    end

    describe "as an org admin" do
      login_org_admin

      let(:userId) { subject.current_user.id }
      let(:orgId)  { subject.current_user.organization_id }
      let!(:org)   { create(:organization, id: orgId) }
      let!(:org2)  { create(:organization, id: orgId + 1) }

      let!(:student1) { create(:student, organization_id: org.id) }
      let!(:student2) { create(:student, organization_id: org2.id) }

      let!(:orgTest)    { create(:org_test, organization_id: org.id) }

      it "returns 403 if creating a test for a student in a different organization." do
        userTest = attributes_for(:user_test, org_test_id: orgTest.id,
                                              user_id: student2.id)
        post :create_user_test, {:userTest => userTest}
        expect(response.status).to eq(403)
      end

      it "returns 200 if creating a test for a student in the same organization." do
        userTest = attributes_for(:user_test, org_test_id: orgTest.id,
                                              user_id: student1.id)
        post :create_user_test, {:userTest => userTest}
        expect(response.status).to eq(200)
        expect(json["userTest"]["user_id"]).to eq(student1.id)
      end
    end

    describe "as a super admin" do
      login_super_admin

      let(:orgId)     { 1 }
      let!(:org)      { create(:organization, id: orgId) }
      let!(:student1) { create(:student, organization_id: org.id) }
      let!(:orgTest)  { create(:org_test, organization_id: org.id) }

      let!(:otherOrg)     { create(:organization, id: orgId + 1) }
      let!(:student2)     { create(:student, organization_id: otherOrg.id) }
      let!(:otherOrgTest) { create(:org_test, organization_id: otherOrg.id) }

      it "returns 200 if creating a test for student1." do
        userTest = attributes_for(:user_test, org_test_id: orgTest.id,
                                              user_id: student1.id)
        post :create_user_test, {:userTest => userTest}
        expect(response.status).to eq(200)
        expect(json["userTest"]["user_id"]).to eq(student1.id)
      end

      it "returns 200 if creating a test for student2 with orgTest in same organization." do
        userTest = attributes_for(:user_test, org_test_id: otherOrgTest.id,
                                              user_id: student2.id)
        post :create_user_test, {:userTest => userTest}
        expect(response.status).to eq(200)
        expect(json["userTest"]["user_id"]).to eq(student2.id)
      end

      # TODO More tests like this across the entire suite
      xit "returns 500 if creating a test for student with orgTest from different organization." do
        userTest = attributes_for(:user_test, org_test_id: orgTest.id,
                                              user_id: student2.id)
        post :create_user_test, {:userTest => userTest}
        expect(response.status).to eq(500)
      end
    end
  end

  describe "PUT /user_test/:id" do

    describe "as a student" do
      login_student

      let(:userId)     { subject.current_user.id }
      let(:orgId)      { subject.current_user.organization_id }
      let(:timeUnitId) { subject.current_user.time_unit_id }

      let!(:org)        { create(:organization, id: orgId) }
      let!(:otherUser)  { create(:student, organization_id: org.id) }
      let!(:orgTest)    { create(:org_test, organization_id: org.id) }

      let!(:student1Test1) { create(:user_test, org_test_id: orgTest.id,
                                                user_id: userId,
                                                time_unit_id: timeUnitId) }
      let!(:student1Test2) { create(:user_test, org_test_id: orgTest.id,
                                                user_id: userId,
                                                time_unit_id: timeUnitId + 1) }

      let!(:student2Test)  { create(:user_test, org_test_id: orgTest.id,
                                                user_id: otherUser.id,
                                                time_unit_id: timeUnitId) }

      it "returns 403 if updating another student's test." do
        updatedOtherUserTest = attributes_for(:user_test, org_test_id: orgTest.id,
                                                          user_id: userId,
                                                          time_unit_id: student1Test1.time_unit_id)
        put :update_user_test, {:id => student2Test.id, :userTest => updatedOtherUserTest}
        expect(response.status).to eq(403)
      end

      it "returns 200 if updating their own test in the time_unit that they're currently in." do
        userTest = attributes_for(:user_test, org_test_id: orgTest.id,
                                              user_id: userId,
                                              time_unit_id: student1Test1.time_unit_id)
        put :update_user_test, {:id => student1Test1.id, :userTest => userTest}
        expect(response.status).to eq(200)
        expect(json["userTest"]["id"]).to eq(student1Test1.id)
      end

      # TODO More tests like this across the entire suite
      xit "returns 403 if updating their own test that's in a time_unit other than the one that they're currently in." do
        userTest = attributes_for(:user_test, org_test_id: orgTest.id,
                                              user_id: userId,
                                              time_unit_id: student1Test1.time_unit_id)
        put :update_user_test, {:id => student1Test2.id, :userTest => userTest}
        expect(response.status).to eq(403)
      end
    end

    describe "as a mentor" do
      login_mentor

      let(:userId) { subject.current_user.id }
      let(:orgId)  { subject.current_user.organization_id }
      let!(:org)   { create(:organization, id: orgId) }

      let!(:student1) { create(:student, organization_id: org.id) }
      let!(:student2) { create(:student, organization_id: org.id) }

      let!(:relationship) { create(:relationship, user_id: student1.id,
                                                  assigned_to_id: userId) }

      let!(:orgTest)    { create(:org_test, organization_id: org.id) }

      let!(:student1Test)  { create(:user_test, org_test_id: orgTest.id,
                                                user_id: student1.id) }
      let!(:student2Test)  { create(:user_test, org_test_id: orgTest.id,
                                                user_id: student2.id) }

      it "returns 403 if updating a test for a student not assigned to them" do
        userTest = attributes_for(:user_test, org_test_id: orgTest.id,
                                              user_id: student1.id)
        put :update_user_test, {:id => student2Test.id, :userTest => userTest}
        expect(response.status).to eq(403)
      end

      it "returns 200 if updating a test for a student assigned to them" do
        userTest = attributes_for(:user_test, org_test_id: orgTest.id,
                                              user_id: student1.id)
        put :update_user_test, {:id => student1Test.id, :userTest => userTest}
        expect(response.status).to eq(200)
        expect(json["userTest"]["id"]).to eq(student1Test.id)
      end
    end

    describe "as an org admin" do
      login_org_admin

      let(:userId) { subject.current_user.id }
      let(:orgId)  { subject.current_user.organization_id }
      let!(:org)   { create(:organization, id: orgId) }
      let!(:org2)  { create(:organization, id: orgId + 1) }

      let!(:student1) { create(:student, organization_id: org.id) }
      let!(:student2) { create(:student, organization_id: org2.id) }

      let!(:orgTest)  { create(:org_test, organization_id: org.id) }
      let!(:org2Test) { create(:org_test, organization_id: org2.id) }

      let!(:student1Test) { create(:user_test, org_test_id: orgTest.id,
                                               user_id: student1.id) }
      let!(:student2Test) { create(:user_test, org_test_id: org2Test.id,
                                               user_id: student2.id) }

      it "returns 403 if updating a test for a student in a different organization." do
        userTest = attributes_for(:user_test, org_test_id: orgTest.id,
                                              user_id: student1.id)
        put :update_user_test, {:id => student2Test.id, :userTest => userTest}
        expect(response.status).to eq(403)
      end

      it "returns 200 if updating a test for a student in the same organization." do
        userTest = attributes_for(:user_test, org_test_id: orgTest.id,
                                              user_id: student1.id)
        put :update_user_test, {:id => student1Test.id, :userTest => userTest}
        expect(response.status).to eq(200)
        expect(json["userTest"]["id"]).to eq(student1Test.id)
      end
    end

    describe "as a super admin" do
      login_super_admin

      let(:orgId) { 1 }
      let!(:org1) { create(:organization, id: orgId) }
      let!(:org2) { create(:organization, id: orgId + 1) }

      let!(:student1) { create(:student, organization_id: org1.id) }
      let!(:student2) { create(:student, organization_id: org2.id) }

      let!(:org1Test) { create(:org_test, organization_id: org1.id) }
      let!(:org2Test) { create(:org_test, organization_id: org2.id) }

      let!(:student1Test) { create(:user_test, org_test_id: org1Test.id,
                                               user_id: student1.id) }
      let!(:student2Test) { create(:user_test, org_test_id: org2Test.id,
                                               user_id: student2.id) }

      it "returns 200 if updating a test for student1." do
        userTest = attributes_for(:user_test, org_test_id: org1Test.id,
                                              user_id: student1.id)
        put :update_user_test, {:id => student1Test.id, :userTest => userTest}
        expect(response.status).to eq(200)
        expect(json["userTest"]["id"]).to eq(student1Test.id)
      end

      it "returns 200 if updating a test for student2." do
        userTest = attributes_for(:user_test, org_test_id: org1Test.id,
                                              user_id: student2.id)
        put :update_user_test, {:id => student2Test.id, :userTest => userTest}
        expect(response.status).to eq(200)
        expect(json["userTest"]["id"]).to eq(student2Test.id)
        expect(json["userTest"]["org_test_id"]).to eq(org2Test.id)
      end
    end
  end

  describe "DELETE /user_test/:id" do

    describe "as a student" do
      login_student

      let(:userId)     { subject.current_user.id }
      let(:orgId)      { subject.current_user.organization_id }
      let(:timeUnitId) { subject.current_user.time_unit_id }

      let!(:org)        { create(:organization, id: orgId) }
      let!(:otherUser)  { create(:student, organization_id: org.id) }
      let!(:orgTest)    { create(:org_test, organization_id: org.id) }

      let!(:student1Test1) { create(:user_test, org_test_id: orgTest.id,
                                                user_id: userId,
                                                time_unit_id: timeUnitId) }
      let!(:student1Test2) { create(:user_test, org_test_id: orgTest.id,
                                                user_id: userId,
                                                time_unit_id: timeUnitId + 1) }

      let!(:student2Test)  { create(:user_test, org_test_id: orgTest.id,
                                                user_id: otherUser.id,
                                                time_unit_id: timeUnitId) }

      it "returns 403 if deleting another student's test." do
        delete :delete_user_test, {:id => student2Test.id}
        expect(response.status).to eq(403)
      end

      it "returns 200 if deleting their own test in the time_unit that they're currently in." do
        delete :delete_user_test, {:id => student1Test1.id}
        expect(response.status).to eq(200)
      end

      # TODO More tests like this across the entire suite
      xit "returns 403 if deleting their own test that's in a time_unit other than the one that they're currently in." do
        delete :delete_user_test, {:id => student1Test2.id}
        expect(response.status).to eq(403)
      end
    end

    describe "as a mentor" do
      login_mentor

      let(:userId) { subject.current_user.id }
      let(:orgId)  { subject.current_user.organization_id }
      let!(:org)   { create(:organization, id: orgId) }

      let!(:student1) { create(:student, organization_id: org.id) }
      let!(:student2) { create(:student, organization_id: org.id) }

      let!(:relationship) { create(:relationship, user_id: student1.id,
                                                  assigned_to_id: userId) }

      let!(:orgTest)    { create(:org_test, organization_id: org.id) }

      let!(:student1Test)  { create(:user_test, org_test_id: orgTest.id,
                                                user_id: student1.id) }
      let!(:student2Test)  { create(:user_test, org_test_id: orgTest.id,
                                                user_id: student2.id) }

      it "returns 403 if deleting a test for a student not assigned to them" do
        delete :delete_user_test, {:id => student2Test.id}
        expect(response.status).to eq(403)
      end

      it "returns 200 if deleting a test for a student assigned to them" do
        delete :delete_user_test, {:id => student1Test.id}
        expect(response.status).to eq(200)
      end
    end

    describe "as an org admin" do
      login_org_admin

      let(:userId) { subject.current_user.id }
      let(:orgId)  { subject.current_user.organization_id }
      let!(:org)   { create(:organization, id: orgId) }
      let!(:org2)  { create(:organization, id: orgId + 1) }

      let!(:student1) { create(:student, organization_id: org.id) }
      let!(:student2) { create(:student, organization_id: org2.id) }

      let!(:orgTest)  { create(:org_test, organization_id: org.id) }
      let!(:org2Test) { create(:org_test, organization_id: org2.id) }

      let!(:student1Test) { create(:user_test, org_test_id: orgTest.id,
                                               user_id: student1.id) }
      let!(:student2Test) { create(:user_test, org_test_id: org2Test.id,
                                               user_id: student2.id) }

      it "returns 403 if deleting a test for a student in a different organization." do
        delete :delete_user_test, {:id => student2Test.id}
        expect(response.status).to eq(403)
      end

      it "returns 200 if updating a test for a student in the same organization." do
        delete :delete_user_test, {:id => student1Test.id}
        expect(response.status).to eq(200)
      end
    end

    describe "as a super admin" do
      login_super_admin

      let(:orgId) { 1 }
      let!(:org1) { create(:organization, id: orgId) }
      let!(:org2) { create(:organization, id: orgId + 1) }

      let!(:student1) { create(:student, organization_id: org1.id) }
      let!(:student2) { create(:student, organization_id: org2.id) }

      let!(:org1Test) { create(:org_test, organization_id: org1.id) }
      let!(:org2Test) { create(:org_test, organization_id: org2.id) }

      let!(:student1Test) { create(:user_test, org_test_id: org1Test.id,
                                               user_id: student1.id) }
      let!(:student2Test) { create(:user_test, org_test_id: org2Test.id,
                                               user_id: student2.id) }

      it "returns 200 if deleting a test for student1." do
        delete :delete_user_test, {:id => student1Test.id}
        expect(response.status).to eq(200)
      end

      it "returns 200 if deleting a test for student2." do
        delete :delete_user_test, {:id => student2Test.id}
        expect(response.status).to eq(200)
      end
    end
  end

end
