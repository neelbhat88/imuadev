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

  describe "POST #create" do

    describe "as a student" do
      login_student

      before(:each) do
        @user = subject.current_user
      end

      it "returns 200 and adds user_class to database" do
        expect {
          post :create, {:user_id => @user.id, user_class: attributes_for(:user_class)}
        }.to change(UserClass, :count).by(1)

        expect(response.status).to eq(200)
        expect(json["user_class"]).to_not be_nil
      end

      it "returns 400 if there is an error creating a user_class" do
        expect {
          post :create, {:user_id => @user.id,
                         user_class: attributes_for(:user_class, name: nil)}
        }.to change(UserClass, :count).by(0)

        expect(response.status).to eq(400)
        expect(json["user_class"]).to be_nil
      end
    end

    describe "as a mentor" do
      login_mentor

      before(:each) do
        @user = create(:student)
      end

      it "returns 200 and adds user_class to database" do
        expect {
          post :create, {:user_id => @user.id, user_class: attributes_for(:user_class)}
        }.to change(UserClass, :count).by(1)

        expect(response.status).to eq(200)
        expect(json["user_class"]).to_not be_nil
      end

      it "returns 400 if there is an error creating a user_class" do
        expect {
          post :create, {:user_id => @user.id,
                         user_class: attributes_for(:user_class, name: nil)}
        }.to change(UserClass, :count).by(0)

        expect(response.status).to eq(400)
        expect(json["user_class"]).to be_nil
      end
    end

    describe "as an admin" do
      login_org_admin

      before(:each) do
        @user = create(:student)
      end

      it "returns 200 and adds user_class to database" do
        expect {
          post :create, {:user_id => @user.id, user_class: attributes_for(:user_class)}
        }.to change(UserClass, :count).by(1)

        expect(response.status).to eq(200)
        expect(json["user_class"]).to_not be_nil
      end

      it "returns 400 if there is an error creating a user_class" do
        expect {
          post :create, {:user_id => @user.id,
                         user_class: attributes_for(:user_class, name: nil)}
        }.to change(UserClass, :count).by(0)

        expect(response.status).to eq(400)
        expect(json["user_class"]).to be_nil
      end
    end

  end

end
