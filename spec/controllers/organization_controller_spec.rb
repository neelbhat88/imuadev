require 'rails_helper'

describe Api::V1::OrganizationController do
  before(:each) do
    @organizationRepository = instance_double("OrganizationRepository")
    @roadmapRepository = instance_double("RoadmapRepository")
    @enabledModules = instance_double("EnabledModules")
    controller.load_services(@organizationRepository, @roadmapRepository, @enabledModules)
  end

  describe "GET /organizations as super admin" do
    login_super_admin

    it "returns object" do
      allow(@organizaitonRepository).to receive(:get_all_organizaitons).and_return(ReturnObject.new(:ok, "info", nil))

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

  describe "GET /organization/:id" do
    context "as an Org Admin" do
      login_org_admin

      it "returns 403 if :id is not current users organization" do
        subject.current_user.organization_id = 10

        get :get_organization, {:id => 5555}

        expect(response.status).to eq(403)
      end
    end

    context "as a Super Admin" do
      login_super_admin

      # ToDo: Why does the mock object still run the code in orgrepo??
      xit "returns 200 for any :id" do
        allow(@organizaitonRepository).to receive(:get_organization).and_return(ReturnObject.new(:ok, "Organization", nil))

        get :get_organization, {:id => 5555}

        expect(response.status).to eq(200)
      end
    end
  end

  # Add tests for Get /organization/:id
  # Not allowed for students, mentors
  # If Org_admin and :id is not the id of the current_user.organization_id then unauthorized

  #describe "GET /organization/:id"
end
