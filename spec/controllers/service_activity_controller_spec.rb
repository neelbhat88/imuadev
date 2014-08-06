require 'rails_helper'

describe Api::V1::ServiceActivityController do

  describe "GET #user_service_activity_events" do
    context "as a student" do
      login_student

      let(:userId) { subject.current_user.id }
      let(:time_unit_id) { subject.current_user.time_unit_id }
      let(:org_id) { subject.current_user.organization_id }

      before :each do
        activity1 = create(:user_service_activity, user_id: subject.current_user.id)
        activity2 = create(:user_service_activity, user_id: subject.current_user.id)
        activity3 = create(:user_service_activity)
        event1 = create(:user_service_activity_event,
                    user_id: subject.current_user.id,
                    time_unit_id: subject.current_user.time_unit_id,
                    user_service_activity_id: activity1.id)
        event2 = create(:user_service_activity_event,
                    user_id: subject.current_user.id,
                    time_unit_id: subject.current_user.time_unit_id,
                    user_service_activity_id: activity2.id)
        event3 = create(:user_service_activity_event)
      end

      it "returns 200 with user_service_activity_events" do
        get :user_service_activity_events, {:id => userId, :time_unit_id => time_unit_id}

        expect(response.status).to eq(200)
        expect(json["user_service_activities"].length).to eq(2)
        expect(json["user_service_activity_events"].length).to eq(2)
      end

      it "returns 403 if current_user is not in :org_id" do
        user = create(:student)
        get :user_service_activity_events, {:id => user.id}

        expect(response.status).to eq(403)
      end

      it "returns 403 if :id is not current student" do
        subject.current_user.id = 1

        get :user_service_activity_events, {:id => '2'}

        expect(response.status).to eq(403)
      end
    end

    context "as a org admin" do
      login_org_admin

      it "returns 403 if current user is not in the same organization as student" do
        user = create(:student, organization_id: 12345)
        subject.current_user.organization_id = 1

        get :user_service_activity_events, {:id => user.id}

        expect(response.status).to eq(403)
      end

      it "returns 200 with user_service_activity_events" do
        user = create(:student)
        activity1 = create(:user_service_activity, user_id: user.id)
        activity2 = create(:user_service_activity, user_id: user.id)
        event1 = create(:user_service_activity_event,
                        user_id: user.id, time_unit_id: user.time_unit_id,
                        user_service_activity_id: activity1.id)
        event2 = create(:user_service_activity_event)

        get :user_service_activity_events, {:id => user.id, :time_unit_id => user.time_unit_id}

        expect(response.status).to eq(200)
        expect(json["user_service_activities"].length).to eq(2)
        expect(json["user_service_activity_events"].length).to eq(1)
      end
    end

  end

  describe "POST #user_service_activity" do
    context "as a student" do
      login_student

      let(:userId) { subject.current_user.id }

      it "returns 200 with user_service_activity" do
        activity1 = attributes_for(:user_service_activity, user_id: subject.current_user.id)
        post :add_user_service_activity, {:service_activity => activity1}

        expect(response.status).to eq(200)
        expect(json["user_service_activity"]["user_id"]).to eq(userId)
      end
    end
  end

  describe "POST #user_service_activity_event" do
    context "as a student" do
      login_student

      let(:userId) { subject.current_user.id }

      it "returns 200 with user_service_activity" do
        event1 = attributes_for(:user_service_activity_event, user_id: subject.current_user.id, )
        post :add_user_service_activity_event, {:service_activity_event => event1}

        expect(response.status).to eq(200)
        expect(json["user_service_activity_event"]["user_id"]).to eq(userId)
      end
    end
  end

  describe "PUT #user_service_activity" do
    context "as a student" do
      login_student

      let(:userId) { subject.current_user.id }
      let(:theActivity) { create(:user_service_activity, user_id: subject.current_user.id) }

      it "returns 200 with user_service_activity" do
        activity1 = attributes_for(:user_service_activity, user_id: subject.current_user.id,
                                   name: 'poopHard')
        put :update_user_service_activity, {:id => theActivity[:id], :service_activity => activity1}

        expect(response.status).to eq(200)
        expect(json["user_service_activity"]["user_id"]).to eq(userId)
      end
    end
  end

  describe "PUT #user_service_activity_event" do
    context "as a student" do
      login_student

      let(:userId) { subject.current_user.id }
      let(:time_unit_id) { subject.current_user.time_unit_id }
      let(:theActivityEvent) { create(:user_service_activity_event, user_id: subject.current_user.id) }

      it "returns 200 with user_service_activity_event" do
        event1 = attributes_for(:user_service_activity_event, user_id: subject.current_user.id, name: 'GettingIt')
        put :update_user_service_activity_event, {:id => theActivityEvent[:id], :service_activity_event => event1}

        expect(response.status).to eq(200)
        expect(json["user_service_activity_event"]["user_id"]).to eq(userId)
      end
    end
  end

  describe "DELETE #user_service_activity" do
    context "as a student" do
      login_student

      let(:userId) { subject.current_user.id }
      let(:theActivity) { create(:user_service_activity, user_id: subject.current_user.id) }

      it "returns 200 with Deleted User Activity" do
        delete :delete_user_service_activity, {:id => theActivity[:id]}

        expect(response.status).to eq(200)
        expect(json["info"]).to eq('Deleted User Service Activity')
      end
    end
  end

  describe "DELETE #user_service_activity_event" do
    context "as a student" do
      login_student

      let(:userId) { subject.current_user.id }
      let(:time_unit_id) { subject.current_user.time_unit_id }
      let(:theActivityEvent) { create(:user_service_activity_event, user_id: subject.current_user.id) }

      it "returns 200 with user_service_activity_event" do
        delete :delete_user_service_activity_event, {:id => theActivityEvent[:id]}

        expect(response.status).to eq(200)
        expect(json["info"]).to eq('Deleted User Service Activity Event')
      end
    end
  end

end
