require 'rails_helper'

describe Api::V1::UserExtracurricularActivityController do

  describe "GET #user_extracurricular_activity_details" do
    context "as a student" do
      login_student

      let(:userId) { subject.current_user.id }
      let(:time_unit_id) { subject.current_user.time_unit_id }
      let(:org_id) { subject.current_user.organization_id }

      before :each do
        activity1 = create(:user_extracurricular_activity, user_id: subject.current_user.id)
        activity2 = create(:user_extracurricular_activity, user_id: subject.current_user.id)
        activity3 = create(:user_extracurricular_activity)
        detail1 = create(:user_extracurricular_activity_detail, user_id: subject.current_user.id, time_unit_id: subject.current_user.time_unit_id)
        detail2 = create(:user_extracurricular_activity_detail, user_id: subject.current_user.id, time_unit_id: subject.current_user.time_unit_id)
        detail3 = create(:user_extracurricular_activity_detail)
      end

      it "returns 200 with user_extracurricular_activity_details" do
        get :index , {:user_id => userId, :time_unit_id => time_unit_id}

        expect(response.status).to eq(200)
        expect(json["user_extracurricular_activities"].length).to eq(2)
        expect(json["user_extracurricular_details"].length).to eq(2)
      end

      it "returns 403 if current_user is not in :org_id" do
        user = create(:student)
        get :index, {:user_id => user.id, :time_unit_id => time_unit_id}

        expect(response.status).to eq(403)
      end

      it "returns 403 if :id is not current student" do
        subject.current_user.id = 1
        user = create(:student, id: 9)

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

      it "returns 200 with user_extracurricular_activity_details" do
        user = create(:student)
        activity1 = create(:user_extracurricular_activity, user_id: user.id)
        activity2 = create(:user_extracurricular_activity, user_id: user.id)
        detail1 = create(:user_extracurricular_activity_detail, user_id: user.id, time_unit_id: user.time_unit_id)
        detail2 = create(:user_extracurricular_activity_detail, user_id: user.id)

        get :index, {:user_id => user.id, :time_unit_id => user.time_unit_id}

        expect(response.status).to eq(200)
        expect(json["user_extracurricular_activities"].length).to eq(2)
        expect(json["user_extracurricular_details"].length).to eq(1)
      end
    end

  end

  describe "POST #user_extracurricular_activity" do
    context "as a student" do
      login_student

      let(:userId) { subject.current_user.id }

      it "returns 200 with user_extracurricular_activity" do
        activity1 = attributes_for(:user_extracurricular_activity, user_id: subject.current_user.id)
        detail1 = attributes_for(:user_extracurricular_activity_detail, user_id: subject.current_user.id)
        post :create, {:user_id => userId, :user_extracurricular_activity => activity1,
                       :user_extracurricular_detail => detail1}

        expect(response.status).to eq(200)
        expect(json["user_extracurricular_activity"]["user_id"]).to eq(userId)
        expect(json["user_extracurricular_detail"]["user_id"]).to eq(userId)
      end
    end
  end

  describe "PUT #user_extracurricular_activity" do
    context "as a student" do
      login_student

      let(:userId) { subject.current_user.id }
      let(:theActivity) { create(:user_extracurricular_activity, user_id: subject.current_user.id) }
      let(:theActivityDetail) { create(:user_extracurricular_activity_detail, user_id: subject.current_user.id) }

      it "returns 200 with user_extracurricular_activity" do
        activity1 = attributes_for(:user_extracurricular_activity, user_id: subject.current_user.id,
                                   name: 'poopHard', id: theActivity[:id])
        detail1 = attributes_for(:user_extracurricular_activity_detail, user_id: subject.current_user.id, id: theActivityDetail[:id])
        put :update, {:id => activity1[:id], :user_extracurricular_activity => activity1, :user_extracurricular_detail => detail1}

        expect(response.status).to eq(200)
        expect(json["user_extracurricular_activity"]["user_id"]).to eq(userId)
        expect(json["user_extracurricular_detail"]["user_id"]).to eq(userId)
      end
    end
  end

  describe "DELETE #user_extracurricular_activity with details in multipe time_units" do
    context "as a student" do
      login_student

      before :each do
        userId = subject.current_user.id
        activity = create(:user_extracurricular_activity, user_id: userId, id: 5)
        activityDetail1 =  create(:user_extracurricular_activity_detail, user_id: userId, time_unit_id: 5, user_extracurricular_activity_id: 5)
        activityDetail2 =  create(:user_extracurricular_activity_detail, user_id: userId, time_unit_id: 7, user_extracurricular_activity_id: 5)
      end

      let(:theActivityDetail3) { create(:user_extracurricular_activity_detail,
                                          user_id: subject.current_user.id,
                                          time_unit_id: 9,
                                          user_extracurricular_activity_id: 5) }

      it "returns 200 with Deleted Details for User Activity Id" do
        delete :destroy, {:id => 5, :time_unit_id => 5}

        expect(response.status).to eq(200)
        expect(json["info"]).to eq("Successfully deleted all Details in this semester for Extracurricular Activity, id: #{theActivityDetail3[:user_extracurricular_activity_id]}")
      end

    end
  end

  describe "DELETE #user_extracurricular_activity with details only in one time_unit" do
    context "as a student" do
      login_student

      before :each do
        userId = subject.current_user.id
        activity = create(:user_extracurricular_activity, user_id: userId, id: 5)
        activityDetail1 =  create(:user_extracurricular_activity_detail, user_id: userId, time_unit_id: 5, user_extracurricular_activity_id: 5)
      end

      let(:theActivityDetail2) { create(:user_extracurricular_activity_detail,
                                          user_id: subject.current_user.id,
                                          time_unit_id: 5,
                                          user_extracurricular_activity_id: 5) }

      it "returns 200 with Deleted Details for User Activity Id" do
        delete :destroy, {:id => 5, :time_unit_id => 5}

        expect(response.status).to eq(200)
        expect(json["info"]).to eq("Successfully deleted Extracurricular Activity, id: #{theActivityDetail2[:user_extracurricular_activity_id]}")
      end

    end
  end

end
