require 'rails_helper'

describe Api::V1::UserServiceHourController do

  describe "POST #user_service_hour" do
    context "as a student" do
      login_student

      let(:userId) { subject.current_user.id }

      it "returns 200 with user_service_hour" do
        hour1 = attributes_for(:user_service_hour, user_id: subject.current_user.id)
        post :create, {:user_id => userId, :user_service_hour => hour1}

        expect(response.status).to eq(200)
        expect(json["user_service_hour"]["user_id"]).to eq(userId)
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
        put :update, {:id => theOrganizationHour[:id], :user_service_hour => hour1}

        expect(response.status).to eq(200)
        expect(json["user_service_hour"]["user_id"]).to eq(userId)
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
        delete :destroy, {:id => theOrganizationHour[:id]}

        expect(response.status).to eq(200)
        expect(json["info"]).to eq("Successfully deleted Service Hour, id: #{theOrganizationHour[:id]}")
      end
    end
  end

end
