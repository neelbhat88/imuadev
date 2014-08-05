require 'rails_helper'

describe Api::V1::ProgressController do
  describe "GET #overall_progress" do
    login_student
    let(:userId) { subject.current_user.id }

    it "returns 200 with correct progress object" do
      orgId = subject.current_user.organization_id

      m1 = create(:milestone, organization_id: orgId, time_unit_id: 1, points: 10)
      m2 = create(:milestone, organization_id: orgId, time_unit_id: 2, points: 20)
      m3 = create(:milestone, organization_id: orgId, time_unit_id: 3, points: 30)

      create(:user_milestone, user_id: userId, milestone_id: m2.id, time_unit_id: m2.time_unit_id)

      get :overall_progress, {:id => userId}

      expect(response.status).to eq(200)
      expect(json["overall_progress"]["totalPoints"]).to eq(60)
      expect(json["overall_progress"]["totalUserPoints"]).to eq(20)
      expect(json["overall_progress"]["percentComplete"]).to eq(33)
    end
  end

  describe "GET #user_classes" do
    context "as a student" do
      login_student

      let(:userId) { subject.current_user.id }
      let(:time_unit_id) { subject.current_user.time_unit_id }
      let(:org_id) { subject.current_user.organization_id }

      before :each do
        class1 = create(:user_class, user_id: subject.current_user.id, time_unit_id: subject.current_user.time_unit_id)
        class2 = create(:user_class, user_id: subject.current_user.id, time_unit_id: subject.current_user.time_unit_id)
        class3 = create(:user_class)
      end

      it "returns 200 with user_classes" do
        get :user_classes, {:id => userId, :time_unit_id => time_unit_id}

        expect(response.status).to eq(200)
        expect(json["user_classes"].length).to eq(2)
      end

      it "returns 403 if current_user is not in :org_id" do
        user = create(:student)
        get :user_classes, {:id => user.id, :time_unit_id => time_unit_id}

        expect(response.status).to eq(403)
      end

      it "returns 403 if :id is not current student" do
        subject.current_user.id = 1

        get :user_classes, {:id => '2', :time_unit_id => time_unit_id}

        expect(response.status).to eq(403)
      end
    end

    context "as a org admin" do
      login_org_admin

      it "returns 403 if current user is not in the same organization as student" do
        user = create(:student, organization_id: 12345)
        subject.current_user.organization_id = 1

        get :user_classes, {:id => user.id, :time_unit_id => user.time_unit_id}

        expect(response.status).to eq(403)
      end

      it "returns 200 with user_classes" do
        user = create(:student)
        class1 = create(:user_class, user_id: user.id, time_unit_id: user.time_unit_id)
        class2 = create(:user_class, user_id: user.id)

        get :user_classes, {:id => user.id, :time_unit_id => user.time_unit_id}

        expect(response.status).to eq(200)
        expect(json["user_classes"].length).to eq(1)
      end
    end

  end

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
        get :user_service_activity_events, {:id => user.id, :time_unit_id => time_unit_id}

        expect(response.status).to eq(403)
      end

      it "returns 403 if :id is not current student" do
        subject.current_user.id = 1

        get :user_service_activity_events, {:id => '2', :time_unit_id => time_unit_id}

        expect(response.status).to eq(403)
      end
    end

    context "as a org admin" do
      login_org_admin

      it "returns 403 if current user is not in the same organization as student" do
        user = create(:student, organization_id: 12345)
        subject.current_user.organization_id = 1

        get :user_service_activity_events, {:id => user.id, :time_unit_id => user.time_unit_id}

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

  describe "GET #user_extracurricular_activity_events" do
    context "as a student" do
      login_student

      let(:userId) { subject.current_user.id }
      let(:time_unit_id) { subject.current_user.time_unit_id }
      let(:org_id) { subject.current_user.organization_id }

      before :each do
        activity1 = create(:user_extracurricular_activity, user_id: subject.current_user.id)
        activity2 = create(:user_extracurricular_activity, user_id: subject.current_user.id)
        activity3 = create(:user_extracurricular_activity)
        event1 = create(:user_extracurricular_activity_event, user_id: subject.current_user.id, time_unit_id: subject.current_user.time_unit_id)
        event2 = create(:user_extracurricular_activity_event, user_id: subject.current_user.id, time_unit_id: subject.current_user.time_unit_id)
        event3 = create(:user_extracurricular_activity_event)
      end

      it "returns 200 with user_extracurricular_activity_events" do
        get :user_extracurricular_activity_events, {:id => userId, :time_unit_id => time_unit_id}

        expect(response.status).to eq(200)
        expect(json["user_extracurricular_activities"].length).to eq(2)
        expect(json["user_extracurricular_activity_events"].length).to eq(2)
      end

      it "returns 403 if current_user is not in :org_id" do
        user = create(:student)
        get :user_extracurricular_activity_events, {:id => user.id, :time_unit_id => time_unit_id}

        expect(response.status).to eq(403)
      end

      it "returns 403 if :id is not current student" do
        subject.current_user.id = 1

        get :user_extracurricular_activity_events, {:id => '2', :time_unit_id => time_unit_id}

        expect(response.status).to eq(403)
      end
    end

    context "as a org admin" do
      login_org_admin

      it "returns 403 if current user is not in the same organization as student" do
        user = create(:student, organization_id: 12345)
        subject.current_user.organization_id = 1

        get :user_extracurricular_activity_events, {:id => user.id, :time_unit_id => user.time_unit_id}

        expect(response.status).to eq(403)
      end

      it "returns 200 with user_extracurricular_activity_events" do
        user = create(:student)
        activity1 = create(:user_extracurricular_activity, user_id: user.id)
        activity2 = create(:user_extracurricular_activity, user_id: user.id)
        event1 = create(:user_extracurricular_activity_event, user_id: user.id, time_unit_id: user.time_unit_id)
        event2 = create(:user_extracurricular_activity_event, user_id: user.id)

        get :user_extracurricular_activity_events, {:id => user.id, :time_unit_id => user.time_unit_id}

        expect(response.status).to eq(200)
        expect(json["user_extracurricular_activities"].length).to eq(2)
        expect(json["user_extracurricular_activity_events"].length).to eq(1)
      end
    end

  end

end
