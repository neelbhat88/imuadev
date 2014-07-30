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
        student1 = create(:student)
        student2 = create(:student)
        student3 = create(:student)
        mentor = create(:mentor)

        create(:relationship, user_id: student1.id, assigned_to_id: mentor.id)
        create(:relationship, user_id: student2.id, assigned_to_id: mentor.id)
        create(:relationship, user_id: mentor.id, assigned_to_id: student3.id)

        get :get_assigned_students, {:id => mentor.id}

        expect(response.status).to eq(200)
        expect(json["students"].length).to eq(2)
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
end
