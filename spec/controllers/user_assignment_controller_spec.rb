require 'rails_helper'

describe Api::V1::UserAssignmentController do

  describe "GET /users/:user_id/user_assignment" do

    describe "as a mentor" do
      login_mentor

      let(:orgId)     { subject.current_user.organization_id }
      let(:userId)    { subject.current_user.id }

      let!(:student)  { create(:student, organization_id: orgId) }
      let(:studentId) { subject.current_user.id }

      let!(:assignment)      { create(:assignment, user_id: userId) }
      let!(:user_assignment) { create(:user_assignment,
                                       assignment_id: assignment.id,
                                       user_id:       studentId) }

      it "returns 200 if user in same organization" do
        get :index, {:user_id => studentId}
        expect(response.status).to eq(200)
        expect(json["user_assignments"][0]["user_id"]).to eq(studentId)
        expect(json["user_assignments"][0]["assignment_id"]).to eq(assignment.id)
      end

    end

    describe "as a org admin" do
      login_org_admin

      let(:adminId) { subject.current_user.id }
      let(:orgId)   { subject.current_user.organization_id }

      let!(:assignment)      { create(:assignment, user_id: adminId) }
      let!(:student)         { create(:student, organization_id: orgId) }
      let!(:other_student)   { create(:student, organization_id: orgId + 1) }
      let!(:user_assignment) { create(:user_assignment,
                                       assignment_id: assignment.id,
                                       user_id:       student.id) }

      xit "returns 403 if not in same organization" do
        get :index, {:id => other_student.id}
        expect(response.status).to eq(403)
      end

      it "returns 200 if same organization" do
        get :index, {:user_id => student.id}
        expect(response.status).to eq(200)
        expect(json["user_assignments"][0]["user_id"]).to eq(student.id)
        expect(json["user_assignments"][0]["assignment_id"]).to eq(assignment.id)
      end
    end
  end

  describe "POST /users/:user_id/user_assignment" do

    describe "as a mentor" do
      login_mentor

      let(:userId)     { subject.current_user.id }

      let(:orgId)      { subject.current_user.organization_id }
      let(:otherOrgId) { orgId + 1 }

      let!(:student)       { create(:student, organization_id: orgId) }
      let!(:other_student) { create(:student, organization_id: otherOrgId) }

      let!(:assignment)       { create(:assignment, user_id: userId) }
      let!(:other_assignment) { create(:assignment, user_id: userId + 1) }

      xit "returns 403 if a mentor tries to create a UserAssignment for an Assignment that's not theirs" do
        user_assignment = attributes_for(:user_assignment,
                                          assignment_id: other_assignment.id,
                                          user_id:       student.id)
        post :create, {:user_id => student.id, :user_assignment => user_assignment}
        expect(response.status).to eq(403)
      end

      xit "returns 403 if a mentor tries to create a UserAssignment for a User not in their Organization" do
        user_assignment = attributes_for(:user_assignment,
                                          assignment_id: assignment.id,
                                          user_id: student.id)
        post :create, {:user_id => other_student.id, :user_assignment => user_assignment}
        expect(response.status).to eq(403)
      end

      it "returns 200 if a mentor tries to create a UserAssignment (with incorrect json)" do
        user_assignment = attributes_for(:user_assignment,
                                          assignment_id: assignment.id,
                                          user_id:       other_student.id)
        post :create, {:user_id => student.id, :user_assignment => user_assignment}
        expect(response.status).to eq(200)
        expect(json["user_assignment"]["assignment_id"]).to eq(assignment.id)
        expect(json["user_assignment"]["user_id"]).to eq(student.id)
      end
    end

  end

  describe "PUT /user_assignment/:id" do

    describe "as an org admin" do
      login_org_admin

      let(:userId)      { subject.current_user.id }
      let(:orgId)       { subject.current_user.organization_id }
      let(:otherOrgId)  { orgId + 1 }

      let!(:student)       { create(:student, organization_id: orgId) }
      let!(:other_student) { create(:student, organization_id: otherOrgId) }

      let!(:assignment)       { create(:assignment, user_id: userId) }
      let!(:other_assignment) { create(:assignment, user_id: userId + 1) }

      let!(:user_assignment)       { create(:user_assignment,
                                             assignment_id: assignment.id,
                                             user_id: student.id) }
      let!(:other_user_assignment) { create(:user_assignment,
                                             assignment_id: other_assignment.id,
                                             user_id: other_student.id) }

      xit "returns 403 if an admin tries to update a UserAssignment not in their Organization" do
        mod_user_assignment = attributes_for(:user_assignment,
                                             assignment_id: assignment.id,
                                             user_id:       student.id)
        put :update, {:id => other_user_assignment.id, :user_assignment => mod_user_assignment}
        expect(response.status).to eq(403)
      end

      it "returns 200 if an admin tries to update a UserAssignment (with incorrect json)" do
        mod_user_assignment = attributes_for(:user_assignment,
                                             assignment_id: other_assignment.id,
                                             user_id:       other_student.id,
                                             status:        555)
        put :update, {:id => user_assignment.id, :user_assignment => mod_user_assignment}
        expect(response.status).to eq(200)
        expect(json["user_assignment"]["assignment_id"]).to eq(assignment.id)
        expect(json["user_assignment"]["user_id"]).to eq(student.id)
        expect(json["user_assignment"]["status"]).to eq(555)
      end
    end

  end

  describe "DELETE /user_assignment/:id" do

    describe "as a student" do
      login_student

      let(:studentId) { subject.current_user.id }

      let!(:assignment)      { create(:assignment,
                                       user_id: studentId) }
      let!(:user_assignment) { create(:user_assignment,
                                       assignment_id: assignment.id,
                                       user_id: studentId) }

      xit "returns 403 if a student tries to delete their own UserAssignment" do
        delete :destroy, {:id => user_assignment.id}
        expect(response.status).to eq(403)
      end
    end

    describe "as an org admin" do
      login_org_admin

      let(:orgId)      { subject.current_user.organization_id }
      let(:otherOrgId) { orgId + 1 }

      let!(:student)       { create(:student, organization_id: orgId) }
      let!(:other_student) { create(:student, organization_id: otherOrgId) }

      let!(:assignment)       { create(:assignment, user_id: subject.current_user.id) }
      let!(:other_assignment) { create(:assignment, user_id: other_student.id) }

      let!(:user_assignment)       { create(:user_assignment,
                                             assignment_id: assignment.id,
                                             user_id: student.id) }
      let!(:other_user_assignment) { create(:user_assignment,
                                             assignment_id: other_assignment.id,
                                             user_id: other_student.id) }

      xit "returns 403 if an admin tries to delete a UserAssignment for an Assignment not in their Organization" do
        delete :destroy, {:id => other_assignment.id}
        expect(response.status).to eq(403)
      end

      it "returns 200 if an admin tries to delete a UserAssignment in their Organization" do
        delete :destroy, {:id => user_assignment.id}
        expect(response.status).to eq(200)
      end
    end
  end
end
