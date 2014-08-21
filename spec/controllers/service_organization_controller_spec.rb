require 'rails_helper'

describe Api::V1::ServiceOrganizationController do

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
        get :user_service_organizations_hours, {:id => userId, :time_unit_id => time_unit_id}

        expect(response.status).to eq(200)
        expect(json["user_service_organizations"].length).to eq(2)
        expect(json["user_service_hours"].length).to eq(2)
      end

      it "returns 403 if current_user is not in :org_id" do
        user = create(:student)
        get :user_service_organizations_hours, {:id => user.id}

        expect(response.status).to eq(403)
      end

      it "returns 403 if :id is not current student" do
        subject.current_user.id = 1
        user = create(:student, id: 2)

        get :user_service_organizations_hours, {:id => user.id, :time_unit_id => time_unit_id}

        expect(response.status).to eq(403)
      end
    end

    context "as a org admin" do
      login_org_admin

      it "returns 403 if current user is not in the same organization as student" do
        user = create(:student, organization_id: 12345)
        subject.current_user.organization_id = 1

        get :user_service_organizations_hours, {:id => user.id, :time_unit_id => user.time_unit_id}

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

        get :user_service_organizations_hours, {:id => user.id, :time_unit_id => user.time_unit_id}

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

      it "returns 200 with user_service_organization" do
        organization1 = attributes_for(:user_service_organization, user_id: subject.current_user.id)
        post :add_user_service_organization, {:user_service_organization => organization1}

        expect(response.status).to eq(200)
        expect(json["user_service_organization"]["user_id"]).to eq(userId)
      end
    end
  end

  describe "POST #user_service_hour" do
    context "as a student" do
      login_student

      let(:userId) { subject.current_user.id }

      it "returns 200 with user_service_hour" do
        hour1 = attributes_for(:user_service_hour, user_id: subject.current_user.id)
        post :add_user_service_hour, {:user_service_hour => hour1}

        expect(response.status).to eq(200)
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
        put :update_user_service_organization, {:id => theOrganization[:id], :user_service_organization => organization1}

        expect(response.status).to eq(200)
        expect(json["user_service_organization"]["user_id"]).to eq(userId)
      end
    end
  end

  describe "PUT #user_service_hour" do
    context "as a student" do
      login_student

      let(:userId) { subject.current_user.id }
      let(:time_unit_id) { subject.current_user.time_unit_id }
      let(:theOrganizationHour) { create(:user_service_hour, user_id: subject.current_user.id) }

      it "returns 200 with user_service_hour" do
        hour1 = attributes_for(:user_service_hour, user_id: subject.current_user.id, name: 'GettingIt')
        put :update_user_service_hour, {:id => theOrganizationHour[:id], :user_service_hour => hour1}

        expect(response.status).to eq(200)
        expect(json["user_service_hour"]["user_id"]).to eq(userId)
      end
    end
  end

  describe "DELETE #user_service_organization" do
    context "as a student" do
      login_student

      let(:userId) { subject.current_user.id }
      let(:theOrganization) { create(:user_service_organization, user_id: subject.current_user.id) }

      it "returns 200 with Deleted User Organization" do
        delete :delete_user_service_organization, {:id => theOrganization[:id]}

        expect(response.status).to eq(200)
        expect(json["info"]).to eq("Successfully deleted Service Organization, id: #{theOrganization[:id]}")
      end
    end
  end

  describe "DELETE #user_service_hour" do
    context "as a student" do
      login_student

      let(:userId) { subject.current_user.id }
      let(:time_unit_id) { subject.current_user.time_unit_id }
      let(:theOrganizationHour) { create(:user_service_hour, user_id: subject.current_user.id) }

      it "returns 200 with user_service_hour" do
        delete :delete_user_service_hour, {:id => theOrganizationHour[:id]}

        expect(response.status).to eq(200)
        expect(json["info"]).to eq("Successfully deleted Service Hour, id: #{theOrganizationHour[:id]}")
      end
    end
  end

end
