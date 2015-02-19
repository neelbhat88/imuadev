require 'rails_helper'

describe Api::V1::UsersController do
  describe "GET /users/:id" do

    describe "as a student" do
      login_student

      it "returns 403 if a student tries to see another student's profile" do
        student = create(:student)

        get :show, {:id => student.id}

        expect(response.status).to eq(403)
      end

      it "returns 200 with User" do
        get :show, {:id => subject.current_user.id}

        expect(response.status).to eq(200)
        expect(json["user"]["id"]).to eq(subject.current_user.id)
      end

    end

    describe "as a org admin" do
      login_org_admin

      it "returns 403 if not in same organization" do
        student = create(:student, organization_id: 12345)
        subject.current_user.organization_id = 1

        get :show, {:id => student.id}

        expect(response.status).to eq(403)
      end

      it "returns 200 with User" do
        student = create(:student)

        get :show, {:id => student.id}

        expect(response.status).to eq(200)
        expect(json["user"]["id"]).to eq(student.id)
      end
    end
  end

  describe "Login as org admin" do
    login_org_admin

    it "should set current_user" do
      expect(subject.current_user).not_to be_nil
    end

    it "should set role to org admin" do
      expect(subject.current_user.org_admin?).to eq(true)
      expect(subject.current_user.role).to eq(Constants.UserRole[:ORG_ADMIN])
    end
  end

  describe "Login as student" do
    login_student

    it "should set current_user" do
      expect(subject.current_user).not_to be_nil
    end

    it "should set role to student" do
      expect(subject.current_user.student?).to eq(true)
      expect(subject.current_user.role).to eq(Constants.UserRole[:STUDENT])
    end
  end

  describe "Login as mentor" do
    login_mentor

    it "should set current_user" do
      expect(subject.current_user).not_to be_nil
    end

    it "should set role to mentor" do
      expect(subject.current_user.mentor?).to eq(true)
      expect(subject.current_user.role).to eq(Constants.UserRole[:MENTOR])
    end
  end

  describe "Login as super admin" do
    login_super_admin

    it "should set current_user" do
      expect(subject.current_user).not_to be_nil
    end

    it "should set role to super admin" do
      expect(subject.current_user.super_admin?).to eq(true)
      expect(subject.current_user.role).to eq(Constants.UserRole[:SUPER_ADMIN])
    end
  end

  context "Relationships" do
    login_mentor

    describe "POST #assign" do
      it "returns 200 and assigns student to mentor" do
        student = create(:student)
        mentor = create(:mentor)

        post :assign, {:id => mentor.id, :assignee_id => student.id}

        relation = Relationship.where(:user_id => student.id, :assigned_to_id => mentor.id)

        expect(relation).to_not be_nil
        expect(response.status).to eq(200)
        expect(json["student"]["id"]).to eq(student.id)
      end

      it "returns 409 if student is already assigned to mentor" do
        student = create(:student)
        mentor = create(:mentor)

        Relationship.create(:user_id => student.id, :assigned_to_id => mentor.id)

        post :assign, {:id => mentor.id, :assignee_id => student.id}

        expect(response.status).to eq(409)
      end
    end

    describe "DELETE #unassign" do
      it "returns 200 and deletes the relationship between the student and mentor" do
        create(:relationship, user_id: 1, assigned_to_id: 2)

        delete :unassign, {:id => 2, :assignee_id => 1}

        relation = Relationship.where(:user_id => 1, :assigned_to_id => 2)[0]

        expect(relation).to be_nil
        expect(response.status).to eq(200)
      end
    end

    describe "GET #get_assigned_students" do
      it "returns 200 and students object with assigned students" do
        org = create(:organization)
        student1 = create(:student, organization_id: org.id)
        student2 = create(:student, organization_id: org.id)
        student3 = create(:student, organization_id: org.id)
        mentor = create(:mentor, organization_id: org.id)

        create(:relationship, user_id: student1.id, assigned_to_id: mentor.id)
        create(:relationship, user_id: student2.id, assigned_to_id: mentor.id)
        create(:relationship, user_id: mentor.id, assigned_to_id: student3.id)

        get :get_assigned_students, {:id => mentor.id}

        expect(response.status).to eq(200)
      end
    end

    describe "GET #get_assigned_mentors" do
      it "returns 200 and mentors object with assigned mentors" do
        student1 = create(:student)
        student2 = create(:student)
        student3 = create(:student)
        mentor = create(:mentor)

        create(:relationship, user_id: student1.id, assigned_to_id: mentor.id)
        create(:relationship, user_id: student2.id, assigned_to_id: mentor.id)
        create(:relationship, user_id: mentor.id, assigned_to_id: student3.id)

        get :get_assigned_mentors, {:id => student1.id}

        expect(response.status).to eq(200)
        expect(json["mentors"].length).to eq(1)
      end
    end

  end

  context "Assignments" do

    describe "GET /users/:id/assignments" do

      describe "as a mentor" do
        login_mentor

        let(:mentorId) { subject.current_user.id }

        let!(:assignment) { create(:assignment, assignment_owner_type: "User", assignment_owner_id: mentorId) }

        xit "returns 403 if a mentor tries to see another user's Assignments" do
          otherUserId = mentorId + 1
          get :assignments, {id: otherUserId}
          expect(response.status).to eq(403)
        end

        it "returns 200 if same user" do
          get :assignments, {id: mentorId}
          expect(response.status).to eq(200)
          expect(json["organization"]["users"][0]["assignments"][0]["assignment_owner_id"]).to eq(mentorId)
        end

      end

    end

    describe "POST /users/:id/assignment" do

      describe "as a mentor" do
        login_mentor

        let(:userId)      { subject.current_user.id }
        let(:otherUserId) { userId + 1 }

        xit "returns 403 if a mentor tries to create an Assignment for another User" do
          assignment = attributes_for(:assignment, assignment_owner_type: "User", assignment_owner_id: userId)
          post :assignment, {id: otherUserId, assignment: assignment}
          expect(response.status).to eq(403)
        end

        it "returns 200 if an admin tries to create an Assignment (json has different userId)" do
          mod_assignment = attributes_for(:assignment, assignment_owner_type: "User", assignment_owner_id: otherUserId)
          post :assignment, {id: userId, assignment: mod_assignment}
          expect(response.status).to eq(200)
          expect(json["organization"]["users"][0]["assignments"][0]["assignment_owner_id"]).to eq(userId)
        end
      end

    end

    describe "POST /users/:id/create_assignment_broadcast" do

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

          post :create_assignment_broadcast, {:id => userId,
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

        describe "GET /users/:id/task_assignable_users_tasks" do
          it "returns 200 if a mentor tries to collect their task assignable users' tasks" do
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

  end
end
