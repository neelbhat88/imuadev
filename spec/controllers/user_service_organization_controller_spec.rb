require 'rails_helper'

describe Api::V1::UserServiceOrganizationController do

  describe "GET #user_service_organizations_hours" do
    context "as a student" do
      login_student

      let(:userId) { subject.current_user.id }
      let(:time_unit_id) { subject.current_user.time_unit_id }
      let(:org_id) { subject.current_user.organization_id }

      before :each do
        organization1 = create(:user_service_organization, user_id: subject.current_user.id)
        organization2 = create(:user_service_organization, user_id: subject.current_user.id)
        organization3 = create(:user_service_organization)
        hour1 = create(:user_service_hour,
                    user_id: subject.current_user.id,
                    time_unit_id: subject.current_user.time_unit_id,
                    user_service_organization_id: organization1.id)
        hour2 = create(:user_service_hour,
                    user_id: subject.current_user.id,
                    time_unit_id: subject.current_user.time_unit_id,
                    user_service_organization_id: organization2.id)
        hour3 = create(:user_service_hour)
      end

      it "returns 200 with user_service_organizations_hours" do
        get :index, {:user_id => userId, :time_unit_id => time_unit_id}

        expect(response.status).to eq(200)
        expect(json["user_service_organizations"].length).to eq(2)
        expect(json["user_service_hours"].length).to eq(2)
      end

      it "returns 403 if current_user is not in :org_id" do
        user = create(:student)
        get :index, {:user_id => user.id}

        expect(response.status).to eq(403)
      end

      it "returns 403 if :id is not current student" do
        subject.current_user.id = 1
        user = create(:student, id: 2)

        get :index, {:user_id => user.id, :time_unit_id => time_unit_id}

        expect(response.status).to eq(403)
      end
    end

    context "as a org admin" do
      login_org_admin

      it "returns 403 if current user is not in the same organization as student" do
        user = create(:student, organization_id: 12345)
        subject.current_user.organization_id = 1

        get :index, {:user_id => user.id, :time_unit_id => user.time_unit_id}

        expect(response.status).to eq(403)
      end

      it "returns 200 with user_service_organizations_hours" do
        user = create(:student)
        organization1 = create(:user_service_organization, user_id: user.id)
        organization2 = create(:user_service_organization, user_id: user.id)
        hour1 = create(:user_service_hour,
                        user_id: user.id, time_unit_id: user.time_unit_id,
                        user_service_organization_id: organization1.id)
        hour2 = create(:user_service_hour)

        get :index, {:user_id => user.id, :time_unit_id => user.time_unit_id}

        expect(response.status).to eq(200)
        expect(json["user_service_organizations"].length).to eq(2)
        expect(json["user_service_hours"].length).to eq(1)
      end
    end

  end

  describe "POST #user_service_organization" do
    context "as a student" do
      login_student

      let(:userId) { subject.current_user.id }
      let(:theOrganization) { create(:user_service_organization, user_id: subject.current_user.id) }
      let(:theOrganizationHour) { create(:user_service_hour, user_id: subject.current_user.id) }

      it "returns 200 with user_service_organization and user_service_hour" do
        organization = attributes_for(:user_service_organization, user_id: userId, id: theOrganization[:id])
        hour = attributes_for(:user_service_hour, user_id: userId, user_service_organization_id: theOrganization[:id], id: theOrganizationHour[:id])
        post :create, {:user_id => userId, :user_service_organization => organization,
                       :user_service_hour => hour}

        expect(response.status).to eq(200)
        expect(json["user_service_organization"]["user_id"]).to eq(userId)
        expect(json["user_service_hour"]["user_id"]).to eq(userId)
      end
    end
  end

  describe "PUT #user_service_organization" do
    context "as a student" do
      login_student

      let(:userId) { subject.current_user.id }
      let(:theOrganization) { create(:user_service_organization, user_id: subject.current_user.id) }

      it "returns 200 with user_service_organization" do
        organization1 = attributes_for(:user_service_organization, user_id: subject.current_user.id,
                                       name: 'poopHard')
        put :update, {:id => theOrganization[:id], :user_service_organization => organization1}

        expect(response.status).to eq(200)
        expect(json["user_service_organization"]["user_id"]).to eq(userId)
      end
    end
  end

  describe "DELETE #user_service_organization with hours in multipe time_units" do
    context "as a student" do
      login_student

      before :each do
        userId = subject.current_user.id
        organization = create(:user_service_organization, user_id: userId, id: 5)
        organizationHour1 =  create(:user_service_hour, user_id: userId, time_unit_id: 5, user_service_organization_id: 5)
        organizationHour2 =  create(:user_service_hour, user_id: userId, time_unit_id: 7, user_service_organization_id: 5)
      end

      let(:theOrganizationHour3) { create(:user_service_hour,
                                          user_id: subject.current_user.id,
                                          time_unit_id: 7,
                                          user_service_organization_id: 5) }

      it "returns 200 with Deleted Hours for User Organization Id" do
        delete :destroy, {:id => 5, :time_unit_id => 5}

        expect(response.status).to eq(200)
        expect(json["info"]).to eq("Successfully deleted all Hours in this semester for Service Organization, id: #{theOrganizationHour3[:user_service_organization_id]}")
      end

    end
  end

  describe "DELETE #user_service_organization with hours only in one time_unit" do
    context "as a student" do
      login_student

      before :each do
        userId = subject.current_user.id
        organization = create(:user_service_organization, user_id: userId, id: 5)
        organizationHour1 =  create(:user_service_hour, user_id: userId, time_unit_id: 5, user_service_organization_id: 5)
      end

      let(:theOrganizationHour2) { create(:user_service_hour,
                                          user_id: subject.current_user.id,
                                          time_unit_id: 5,
                                          user_service_organization_id: 5) }

      it "returns 200 with Deleted Hours for User Organization Id" do
        delete :destroy, {:id => 5, :time_unit_id => 5}

        expect(response.status).to eq(200)
        expect(json["info"]).to eq("Successfully deleted Service Organization, id: #{theOrganizationHour2[:user_service_organization_id]}")
      end

    end
  end

end
