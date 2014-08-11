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

end
