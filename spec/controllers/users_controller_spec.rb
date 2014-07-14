require 'rails_helper'

describe Api::V1::UsersController do
  describe "GET /users/:id" do

    describe "as a student" do
      login_student

      it "returns 403 if a student tries to see another student's profile" do
        studentId = subject.current_user.id + 1

        get :show, {:id => studentId}

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
end
