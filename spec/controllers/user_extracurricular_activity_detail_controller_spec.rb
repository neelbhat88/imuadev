require 'rails_helper'

describe Api::V1::UserExtracurricularActivityDetailController do

  describe "PUT #user_extracurricular_activity_detail" do
    context "as a student" do
      login_student

      let(:userId) { subject.current_user.id }
      let(:time_unit_id) { subject.current_user.time_unit_id }
      let(:theActivityDetail) { create(:user_extracurricular_activity_detail, user_id: subject.current_user.id) }

      it "returns 200 with user_extracurricular_activity_detail" do
        detail1 = attributes_for(:user_extracurricular_activity_detail, user_id: subject.current_user.id, name: 'GettingIt', id: theActivityDetail[:id])
        put :update, {:id => theActivityDetail[:id], :user_extracurricular_detail => detail1}

        expect(response.status).to eq(200)
        expect(json["user_extracurricular_detail"]["user_id"]).to eq(userId)
      end
    end
  end

  describe "DELETE #user_extracurricular_activity_detail" do
    context "as a student" do
      login_student

      let(:userId) { subject.current_user.id }
      let(:time_unit_id) { subject.current_user.time_unit_id }
      let(:theActivityDetail) { create(:user_extracurricular_activity_detail, user_id: subject.current_user.id) }

      it "returns 200 with Deleted User Activity Detail" do
        delete :destroy, {:id => theActivityDetail[:id]}

        expect(response.status).to eq(200)
        expect(json["info"]).to eq("Successfully deleted Extracurricular Activity Detail, id: #{theActivityDetail[:id]}")
      end
    end
  end

end
