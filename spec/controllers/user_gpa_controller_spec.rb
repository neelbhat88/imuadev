require 'rails_helper'

describe Api::V1::UserGpaController do

  describe "POST #create" do
    describe "as a student" do
      login_student

      before(:each) do
        @user = subject.current_user
      end

      it "returns 403 forbidden" do
        expectation = expect {
          post :create, {:user_id => @user.id, user_gpa: attributes_for(:user_gpa,
                                                             user_id: @user.id,
                                                             time_unit_id: @user.time_unit_id,
                                                             value: 3.4)}
        }

        expect(response.status).to eq(403)
      end
    end

    describe "as a mentor" do
      login_mentor

      before(:each) do
        @current_user = subject.current_user
        @user = create(:student)
      end

      it "returns 200 and adds user_gpa to database" do
        expectation = expect {
          post :create, {:user_id => @user.id, user_gpa: attributes_for(:user_gpa,
                                                            user_id: @user.id,
                                                            time_unit_id: @user.time_unit_id,
                                                            value: 3.4)}
        }

        expectation.to change(UserGpa, :count).by(1)
        expectation.to change(UserGpaHistory, :count).by(1)

        expect(response.status).to eq(200)
        expect(json["user_gpa"]).to_not be_nil
      end
    end

    describe "as an admin" do
      login_org_admin

      before(:each) do
        @current_user = subject.current_user
        @user = create(:student)
      end

      it "returns 200 and adds user_gpa to database" do
        expectation = expect {
          post :create, {:user_id => @user.id, user_gpa: attributes_for(:user_gpa,
                                                            user_id: @user.id,
                                                            time_unit_id: @user.time_unit_id,
                                                            value: 3.4)}
        }

        expectation.to change(UserGpa, :count).by(1)
        expectation.to change(UserGpaHistory, :count).by(1)

        expect(response.status).to eq(200)
        expect(json["user_gpa"]).to_not be_nil
      end
    end
  end

end
