require 'rails_helper'

describe Api::V1::AssignmentController do

  describe "PUT /assignment/:id" do

    describe "as a mentor" do
      login_mentor

      let(:userId)      { subject.current_user.id }
      let(:otherUserId) { userId + 1 }

      let!(:assignment)       { create(:assignment, assignment_owner_type: "User", assignment_owner_id: userId) }
      let!(:other_assignment) { create(:assignment, assignment_owner_type: "User", assignment_owner_id: otherUserId) }

      it "returns 403 if a mentor tries to update an Assignment under another User" do
        mod_assignment = attributes_for(:assignment,
                                         assignment_owner_type: other_assignment.assignment_owner_type, assignment_owner_id: other_assignment.assignment_owner_id,
                                         assignment_id: other_assignment.id)
        put :update, {:id => other_assignment.id, :assignment => mod_assignment}
        expect(response.status).to eq(403)
      end

      it "returns 200 if an admin tries to update an Assignment (json has different id and user_id)" do
        new_title = "new_title"
        new_desc = "new_desc"
        new_due_datetime = DateTime.new(2001,2,3)

        mod_assignment = attributes_for(:assignment,
                                         id: assignment.id + 1, # Check that ignored
                                         assignment_owner_type: assignment.assignment_owner_type, assignment_owner_id: assignment.assignment_owner_id + 1, # Check that ignored
                                         title: new_title,
                                         description: new_desc,
                                         due_datetime: new_due_datetime)
        put :update, {:id => assignment.id, :assignment => mod_assignment}
        expect(response.status).to eq(200)
        expect(json["assignment"]["id"]).to eq(assignment.id)
        expect(json["assignment"]["assignment_owner_id"]).to eq(userId)
        expect(json["assignment"]["title"]).to eq(new_title)
        expect(json["assignment"]["description"]).to eq(new_desc)
        expect(DateTime.parse(json["assignment"]["due_datetime"]).strftime("%m/%d/%Y")).to eq(new_due_datetime.strftime("%m/%d/%Y"))
      end
    end

  end

  describe "DELETE /assignment/:id" do

    describe "as a mentor" do
      login_mentor

      let(:userId)      { subject.current_user.id }
      let(:otherUserId) { userId + 1 }

      let!(:assignment)       { create(:assignment, assignment_owner_type: "User", assignment_owner_id: userId) }
      let!(:other_assignment) { create(:assignment, assignment_owner_type: "User", assignment_owner_id: otherUserId) }

      it "returns 403 if a mentor tries to delete an Assignment for another User" do
        delete :destroy, {:id => other_assignment.id}
        expect(response.status).to eq(403)
      end

      it "returns 200 if a mentor tries to delete their own Assignment" do
        delete :destroy, {:id => assignment.id}
        expect(response.status).to eq(200)
      end
    end

  end

  describe "Assignment collection" do
    describe "as a mentor" do
      login_mentor

      let(:userId) { subject.current_user.id }
      let(:orgId)  { subject.current_user.organization_id }

      let!(:student1) { create(:student, organization_id: orgId) }
      let!(:student2) { create(:student, organization_id: orgId) }
      let!(:student3) { create(:student, organization_id: orgId) }
      let!(:student4) { create(:student, organization_id: orgId) }

      let!(:assignment1) { create(:assignment, assignment_owner_type: "User", assignment_owner_id: userId) }
      let!(:student1Assignment1) { create(:user_assignment,
                                          assignment_id: assignment1.id,
                                          user_id: student1.id) }
      let!(:student2Assignment1) { create(:user_assignment,
                                          assignment_id: assignment1.id,
                                          user_id: student2.id) }

      let!(:assignment2) { create(:assignment, assignment_owner_type: "User", assignment_owner_id: userId) }
      let!(:student1Assignment2) { create(:user_assignment,
                                          assignment_id: assignment2.id,
                                          user_id: student1.id) }
      let!(:student3Assignment2) { create(:user_assignment,
                                          assignment_id: assignment2.id,
                                          user_id: student3.id) }

      # Assignment other than own
      let!(:orgAdmin) { create(:org_admin, organization_id: orgId) }
      let!(:assignment3) { create(:assignment, assignment_owner_type: "User", assignment_owner_id: orgAdmin.id) }
      let!(:student1Assignment3) { create(:user_assignment,
                                          assignment_id: assignment3.id,
                                          user_id: student1.id) }
      let!(:student4Assignment3) { create(:user_assignment,
                                          assignment_id: assignment3.id,
                                          user_id: student4.id) }

      describe "GET /assignment/:id/collection" do
        it "returns 200 if a mentor tries to collect their own assignment" do
          get :get_assignment_collection, {:id => assignment1.id}
          expect(response.status).to eq(200)
          # expect(json["assignment_collection"]["id"]).to eq(assignment1.id)
          # expect(json["assignment_collection"]["user_assignments"].length).to eq(2)
        end
      end

      describe "GET /users/:id/task_assignable_users_tasks" do
        it "returns 200 if a mentor tries to collect all of their own assignments" do
          get :get_task_assignable_users_tasks, {:id => userId}
          expect(response.status).to eq(200)
          # expect(json["assignment_collections"].length).to eq(2)
          # expect(json["assignment_collections"][0]["user_id"]).to eq(userId)
          # expect(json["assignment_collections"][0]["user_assignments"].length).to eq(2)
          # expect(json["assignment_collections"][1]["user_assignments"].length).to eq(2)
        end
      end

    end # As a mentor
  end # Assignment collection

  describe "POST /users/:user_id/assignment/broadcast" do

    describe "as a mentor" do
      login_mentor

      let(:userId) { subject.current_user.id }
      let(:orgId)  { subject.current_user.organization_id }

      let!(:student1) { create(:student, organization_id: orgId) }
      let!(:student2) { create(:student, organization_id: orgId) }

      it "returns 200 if a mentor tries broadcasting a new assignment" do

        title = "title"
        desc = "desc"
        due_datetime = DateTime.new(2001,2,3)

        assignment = attributes_for(:assignment,
                                    assignment_owner_type: "User", assignment_owner_id: userId + 1, # Check that ignored
                                    title: title,
                                    description: desc,
                                    due_datetime: due_datetime)

        student1Assignment = attributes_for(:user_assignment,
                                            user_id: student1.id)

        student2Assignment = attributes_for(:user_assignment,
                                            user_id: student2.id)

        user_assignments = [student1Assignment, student2Assignment]

        post :broadcast, {:id => userId,
                          :assignment => assignment,
                          :user_assignments => user_assignments}

        expect(response.status).to eq(200)
        # expect(json["assignment_collection"]["user_id"]).to eq(userId)
        # expect(json["assignment_collection"]["title"]).to eq(title)
        # expect(json["assignment_collection"]["description"]).to eq(desc)
        # expect(DateTime.parse(json["assignment_collection"]["due_datetime"]).strftime("%m/%d/%Y")).to eq(due_datetime.strftime("%m/%d/%Y"))
        #
        # user_assignments = json["assignment_collection"]["user_assignments"]
        # expect(user_assignments.length).to eq(2)
        # expect(user_assignments[0]["assignment_id"]).to eq(json["assignment_collection"]["id"])
        # expect(user_assignments[1]["assignment_id"]).to eq(json["assignment_collection"]["id"])
      end

    end
  end

  describe "PUT /assignment/:id/broadcast" do

    describe "as a mentor" do
      login_mentor

      let(:userId) { subject.current_user.id }
      let(:orgId)  { subject.current_user.organization_id }

      let!(:student1) { create(:student, organization_id: orgId) }
      let!(:student2) { create(:student, organization_id: orgId) }
      let!(:student3) { create(:student, organization_id: orgId) }

      let!(:assignment1) { create(:assignment, assignment_owner_type: "User", assignment_owner_id: userId) }
      let!(:student1Assignment1) { create(:user_assignment,
                                          assignment_id: assignment1.id,
                                          user_id: student1.id,
                                          status: 1) }
      let!(:student2Assignment1) { create(:user_assignment,
                                          assignment_id: assignment1.id,
                                          user_id: student2.id,
                                          status: 1) }

      it "returns 200 if a mentor tries a broadcast update of an existing assignment" do
        new_title = "new_title"
        new_desc = "new_desc"
        new_due_datetime = DateTime.new(2001,2,3)

        mod_assignment = attributes_for(:assignment,
                                         id: assignment1.id + 1, # Check that ignored
                                         assignment_owner_type: assignment1.assignment_owner_type, assignment_owner_id: assignment1.assignment_owner_id + 1, # Check that ignored
                                         title: new_title,
                                         description: new_desc,
                                         due_datetime: new_due_datetime)

        mod_student1Assignment1 = attributes_for(:user_assignment,
                                                 id: student1Assignment1.id,
                                                 user_id: student1Assignment1.user_id + 1, # Check that ignored
                                                 assignment_id: student1Assignment1.assignment_id + 1, # Check that ignored,
                                                 status: 0)

        student3Assignment1     = attributes_for(:user_assignment,
                                                 user_id: student3.id,
                                                 assignment_id: assignment1.id)

        mod_user_assignments = [mod_student1Assignment1, student3Assignment1]

        put :broadcast_update, {:id => assignment1.id,
                                :assignment => mod_assignment,
                                :user_assignments => mod_user_assignments}

        expect(response.status).to eq(200)
        # expect(json["assignment_collection"]["id"]).to eq(assignment1.id)
        # expect(json["assignment_collection"]["user_id"]).to eq(assignment1.user_id)
        # expect(json["assignment_collection"]["title"]).to eq(new_title)
        # expect(json["assignment_collection"]["description"]).to eq(new_desc)
        # expect(DateTime.parse(json["assignment_collection"]["due_datetime"]).strftime("%m/%d/%Y")).to eq(new_due_datetime.strftime("%m/%d/%Y"))
        #
        # user_assignments = json["assignment_collection"]["user_assignments"]
        # expect(user_assignments.length).to eq(3)
        #
        # user_assignments.each do |ua|
        #   expect(ua["assignment_id"]).to eq(assignment1.id)
        #   case ua["user_id"]
        #   when student1.id
        #     expect(ua["id"]).to eq(student1Assignment1.id)
        #     expect(ua["status"]).to eq(0)
        #   when student2.id
        #     expect(ua["id"]).to eq(student2Assignment1.id)
        #     expect(ua["status"]).to eq(1)
        #   end
        # end
      end

    end
  end

end
