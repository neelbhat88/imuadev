require 'rails_helper'

describe Api::V1::UserClassController do

  describe "GET #index" do
    login_student

    before(:each) do
      @user = subject.current_user
      create(:user_class, user_id: @user.id, time_unit_id: 1)

      create(:user_class, user_id: @user.id, time_unit_id: 2)
      create(:user_class, time_unit_id: 2)
    end

    it "returns 200 and all user classes for a user" do
      get :index, {:user_id => @user.id}

      expect(response.status).to eq(200)
      expect(json["user_classes"].length).to eq(2)
    end

    it "returns 200 and user classes for a given semester" do
      get :index, {:user_id => @user.id, :time_unit => 1}

      expect(response.status).to eq(200)
      expect(json["user_classes"].length).to eq(1)
    end

    it "returns 200 and no user classes if none in the semester" do
      get :index, {:user_id => @user.id, :time_unit => 1234}

      expect(response.status).to eq(200)
      expect(json["user_classes"].length).to eq(0)
    end

  end

end
