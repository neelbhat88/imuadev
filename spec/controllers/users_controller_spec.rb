require 'rails_helper'

describe Api::V1::UsersController do
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
