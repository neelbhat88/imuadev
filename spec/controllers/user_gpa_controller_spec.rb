require 'rails_helper'

describe Api::V1::UserGpaController do

  describe "POST #create" do

    describe "as a student" do
      login_student

      let(:student)   { subject.current_user }

      it "returns 403 if student tries to enter GPA" do
        user_gpa = attributes_for(:user_gpa,
                                  time_unit_id: student.time_unit_id,
                                  value: 3.7)

        expectation = expect {
          post :create, {:user_id => student.id, :user_gpa => user_gpa}
        }

        expectation.to change(UserGpaHistory, :count).by(0)
        expect(response.status).to eq(403)
      end

    end

    describe "as a mentor" do
      login_mentor

      let(:orgId)     {subject.current_user.organization_id}
      let(:student)   { create(:student, organization_id: orgId) }

      it "returns 200 and adds GPA history if mentor tries to enter GPA" do
        user_gpa = attributes_for(:user_gpa,
                                  time_unit_id: student.time_unit_id,
                                  value: 3.7)


        expectation = expect {
          post :create, {:user_id => student.id, :user_gpa => user_gpa}
        }

        expect(response.status).to eq(200)
      end

    end

    describe "as a org admin" do
      login_org_admin

      let(:orgId)     {subject.current_user.organization_id}
      let(:student)   { create(:student, organization_id: orgId) }

      it "returns 200 and adds GPA history if org admin tries to enter GPA" do
        user_gpa = attributes_for(:user_gpa,
                                  time_unit_id: student.time_unit_id,
                                  value: 3.7)


        expectation = expect {
          post :create, {:user_id => student.id, :user_gpa => user_gpa}
        }

        expect(response.status).to eq(200)
      end
    end

  end
end
