require 'rails_helper'

describe Api::V1::OrganizationController do
  describe "GET /organizations as super admin" do
    login_super_admin
    it "returns object" do
      repo = instance_double("OrganizationRepository", :get_all_organizations => ReturnObject.new(:ok, "info", nil))
      controller.load_services(repo)

      get :all_organizations

      expect(response.status).to eq(200)
      expect(json).to have_key("organizations")
    end
  end

  describe "GET /organizations as org admin" do
    login_org_admin
    it "returns unauthorized" do
      get :all_organizations

      expect(response.status).to eq(401)
    end
  end

  describe "GET /organizations as student" do
    login_student
    it "returns unauthorized" do
      get :all_organizations

      expect(response.status).to eq(401)
    end
  end

  describe "GET /organizations as mentor" do
    login_mentor
    it "returns unauthorized" do
      get :all_organizations

      expect(response.status).to eq(401)
    end
  end

  # Add tests for Get /organization/:id
  # Not allowed for students, mentors
  # If Org_admin and :id is not the id of the current_user.organization_id then unauthorized
  
  #describe "GET /organization/:id"
end
