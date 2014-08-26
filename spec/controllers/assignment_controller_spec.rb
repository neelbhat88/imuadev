require 'rails_helper'

describe Api::V1::AssignmentController do

  describe "GET /users/:user_id/assignment" do

    describe "as a mentor" do
      login_mentor

      let(:mentorId) { subject.current_user.id }

      let!(:assignment) { create(:assignment, user_id: mentorId) }

      xit "returns 403 if a mentor tries to see another user's Assignments" do
        otherUserId = mentorId + 1
        get :index, {:user_id => otherUserId}
        expect(response.status).to eq(403)
      end

      it "returns 200 if same user" do
        get :index, {:user_id => mentorId}
        expect(response.status).to eq(200)
        expect(json["assignments"][0]["user_id"]).to eq(mentorId)
      end

    end

  end

  describe "POST /user/:user_id/assignment" do

    describe "as a mentor" do
      login_mentor

      let(:userId)      { subject.current_user.id }
      let(:otherUserId) { userId + 1 }

      xit "returns 403 if a mentor tries to create an Assignment for another User" do
        assignment = attributes_for(:assignment, user_id: userId)
        post :create, {:user_id => otherUserId, :assignment => assignment}
        expect(response.status).to eq(403)
      end

      it "returns 200 if an admin tries to create an Assignment (json has different userId)" do
        mod_assignment = attributes_for(:assignment, user_id: otherUserId)
        post :create, {:user_id => userId, :assignment => mod_assignment}
        expect(response.status).to eq(200)
        expect(json["assignment"]["user_id"]).to eq(userId)
      end
    end

  end

  describe "PUT /assignment/:id" do

    describe "as a mentor" do
      login_mentor

      let(:userId)      { subject.current_user.id }
      let(:otherUserId) { userId + 1 }

      let!(:assignment)       { create(:assignment, user_id: userId) }
      let!(:other_assignment) { create(:assignment, user_id: otherUserId) }

      xit "returns 403 if a mentor tries to update an Assignment under another User" do
        mod_assignment = attributes_for(:assignment,
                                         user_id: other_assignment.user_id,
                                         assignment_id: other_assignment.id)
        put :update, {:id => other_assignment.id, :assignment => mod_assignment}
        expect(response.status).to eq(403)
      end

      it "returns 200 if an admin tries to update an Assignment (json has different userId and assignment_id)" do
        mod_assignment = attributes_for(:assignment,
                                         user_id: other_assignment.user_id,
                                         assignment_id: other_assignment.id,
                                         title: "new_title",
                                         description: "new_desc")
        put :update, {:id => assignment.id, :assignment => mod_assignment}
        expect(response.status).to eq(200)
        expect(json["assignment"]["id"]).to eq(assignment.id)
        expect(json["assignment"]["user_id"]).to eq(userId)
        expect(json["assignment"]["title"]).to eq("new_title")
        expect(json["assignment"]["description"]).to eq("new_desc")
      end
    end

  end

  describe "DELETE /assignment/:id" do

    describe "as a mentor" do
      login_mentor

      let(:userId)      { subject.current_user.id }
      let(:otherUserId) { userId + 1 }

      let!(:assignment)       { create(:assignment, user_id: userId) }
      let!(:other_assignment) { create(:assignment, user_id: otherUserId) }

      xit "returns 403 if a mentor tries to delete an Assignment for another User" do
        delete :destroy, {:id => other_assignment.id}
        expect(response.status).to eq(403)
      end

      it "returns 200 if a mentor tries to delete their owne Assignment" do
        delete :destroy, {:id => assignment.id}
        expect(response.status).to eq(200)
      end
    end

  end

end
