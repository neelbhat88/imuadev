require 'rails_helper'

describe Api::V1::OrganizationController do

  describe "GET /organizations as super admin" do
    #login_super_admin

    it "returns organization" do
      org1 = create(:organization)
      org2 = create(:organization)

      get_with_token :index
      #get :index

      expect(response.status).to eq(200)
      expect(json["organizations"].length).to eq(2)
    end
  end

  # describe "GET /organizations as org admin" do
  #   login_org_admin
  #   it "returns 403" do
  #     get :index
  #
  #     expect(response.status).to eq(403)
  #   end
  # end
  #
  # describe "GET /organizations as student" do
  #   login_student
  #   it "returns 403" do
  #     get :index
  #
  #     expect(response.status).to eq(403)
  #   end
  # end
  #
  # describe "GET /organizations as mentor" do
  #   login_mentor
  #   it "returns 403" do
  #     get :index
  #
  #     expect(response.status).to eq(403)
  #   end
  # end
  #
  # describe "GET /organization/:id" do
  #   context "as an Org Admin" do
  #     login_org_admin
  #
  #     it "returns 403 if :id is not current users organization" do
  #       subject.current_user.organization_id = 10
  #
  #       get :organization_with_users, {:id => 5555}
  #
  #       expect(response.status).to eq(403)
  #     end
  #   end
  #
  #   context "as a Super Admin" do
  #     login_super_admin
  #
  #     it "returns 200 for any :id" do
  #       org1 = create(:organization)
  #       org2 = create(:organization)
  #
  #       get :organization_with_users, {:id => org1.id}
  #
  #       expect(response.status).to eq(200)
  #       expect(json["organization"]["id"]).to eq(org1.id)
  #     end
  #   end
  #end

  # Add tests for Get /organization/:id
  # Not allowed for students, mentors
  # If Org_admin and :id is not the id of the current_user.organization_id then unauthorized

  #describe "GET /organization/:id"
end
