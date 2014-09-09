require 'rails_helper'

describe Api::V1::UserClassController do

  describe "GET #index" do
    login_student

    before(:each) do
      @user = subject.current_user
      create(:user_class, user_id: @user.id, time_unit_id: 1)
      create(:user_gpa, user_id: @user.id, time_unit_id: 1)

      create(:user_class, user_id: @user.id, time_unit_id: 2)
      create(:user_gpa, user_id: @user.id, time_unit_id: 2)
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
      expect(json["user_gpa"]["user_id"]).to eq(@user.id)
    end

    it "returns 200 and no user classes if none in the semester" do
      get :index, {:user_id => @user.id, :time_unit => 1234}

      expect(response.status).to eq(200)
      expect(json["user_classes"].length).to eq(0)
    end

  end

  describe "PUT #update" do

    describe "as a student" do
      login_student

      before(:each) do
        @user = subject.current_user
        @user_class = create(:user_class, user_id: @user.id, grade: "A")
      end

      it "returns 200 and updates user_class in database" do
        mod_user_class = attributes_for(:user_class, grade: "B")
        expectation = expect {
          put :update, {:id => @user_class.id, user_class: mod_user_class}
          @user_class = UserClass.find(@user_class.id)
        }

        expectation.to change{@user_class.grade}.from("A").to("B")
        expectation.to change(UserClassHistory, :count).by(1)
        expectation.to change(UserGpaHistory, :count).by(1)

        expect(response.status).to eq(200)
        expect(json["user_classes"]).to_not be_nil
        expect(json["user_gpa"]).to_not be_nil
      end

      it "sets modified properties to current user" do
        mod_user_class = attributes_for(:user_class, grade: "B")
        put :update, {:id => @user_class.id, user_class: mod_user_class}

        db_user_class = UserClass.find(@user_class.id)

        expect(db_user_class.modified_by_id).to eq(@user.id)
        expect(db_user_class.modified_by_name).to eq(@user.full_name)
      end
    end

    describe "as a mentor" do
      login_mentor

      before(:each) do
        @current_user = subject.current_user
        @student = create(:student)
        @user_class = create(:user_class, user_id: @student.id, grade: "A")
      end

      it "sets modified properties to current user" do
        mod_user_class = attributes_for(:user_class, grade: "B")
        put :update, {:id => @user_class.id, user_class: mod_user_class}

        db_user_class = UserClass.find(@user_class.id)

        expect(db_user_class.modified_by_id).to eq(@current_user.id)
        expect(db_user_class.modified_by_name).to eq(@current_user.full_name)
      end
    end

  end

  describe "POST #create" do

    describe "as a student" do
      login_student

      before(:each) do
        @user = subject.current_user
        create(:user_gpa, user_id: @user.id, time_unit_id: @user.time_unit_id)
        create(:user_class, user_id: @user.id, time_unit_id: @user.time_unit_id)
      end

      it "returns 200 and adds user_class to database" do
        expectation = expect {
          post :create, {:user_id => @user.id, user_class: attributes_for(:user_class,
                                                             user_id: @user.id,
                                                             time_unit_id: @user.time_unit_id)}
        }

        expectation.to change(UserClass, :count).by(1)
        expectation.to change(UserClassHistory, :count).by(1)
        expectation.to change(UserGpaHistory, :count).by(1)

        expect(response.status).to eq(200)
        expect(json["user_classes"]).to_not be_nil
        expect(json["user_gpa"]).to_not be_nil
      end

      it "sets modified properties to current user" do
        post :create, {:user_id => @user.id, user_class: attributes_for(:user_class,
                                                           user_id: @user.id,
                                                           time_unit_id: @user.time_unit_id)}

        db_user_class = UserClass.where(:user_id => @user.id).first

        expect(db_user_class.modified_by_id).to eq(@user.id)
        expect(db_user_class.modified_by_name).to eq(@user.full_name)
      end

      it "returns 400 if there is an error creating a user_class" do
        expectation = expect {
          post :create, {:user_id => @user.id,
                         user_class: attributes_for(:user_class, name: nil,
                                                      user_id: @user.id,
                                                      time_unit_id: @user.time_unit_id)}
        }

        expectation.to change(UserClass, :count).by(0)
        expectation.to change(UserClassHistory, :count).by(0)
        expectation.to change(UserGpaHistory, :count).by(0)

        expect(response.status).to eq(400)
      end
    end

    describe "as a mentor" do
      login_mentor

      before(:each) do
        @current_user = subject.current_user
        @user = create(:student)
      end

      it "returns 200 and adds user_class to database" do
        expectation = expect {
          post :create, {:user_id => @user.id, user_class: attributes_for(:user_class,
                                                            user_id: @user.id,
                                                            time_unit_id: @user.time_unit_id)}
        }

        expectation.to change(UserClass, :count).by(1)
        expectation.to change(UserClassHistory, :count).by(1)
        expectation.to change(UserGpaHistory, :count).by(1)

        expect(response.status).to eq(200)
        expect(json["user_classes"]).to_not be_nil
      end

      it "sets modified properties to current user" do
        post :create, {:user_id => @user.id, user_class: attributes_for(:user_class,
                                                            user_id: @user.id,
                                                            time_unit_id: @user.time_unit_id)}

        db_user_class = UserClass.where(:user_id => @user.id).first

        expect(db_user_class.modified_by_id).to eq(@current_user.id)
        expect(db_user_class.modified_by_name).to eq(@current_user.full_name)
      end

      it "returns 400 if there is an error creating a user_class" do
        expectation = expect {
          post :create, {:user_id => @user.id,
                         user_class: attributes_for(:user_class, name: nil,
                                                        user_id: @user.id,
                                                        time_unit_id: @user.time_unit_id)}
        }

        expectation.to change(UserClass, :count).by(0)
        expectation.to change(UserClassHistory, :count).by(0)
        expectation.to change(UserGpaHistory, :count).by(0)

        expect(response.status).to eq(400)
        expect(json["user_classes"]).to be_empty
      end
    end

    describe "as an admin" do
      login_org_admin

      before(:each) do
        @user = create(:student)
      end

      it "returns 200 and adds user_class to database" do
        expectation = expect {
          post :create, {:user_id => @user.id, user_class: attributes_for(:user_class)}
        }

        expectation.to change(UserClass, :count).by(1)
        expectation.to change(UserClassHistory, :count).by(1)
        expectation.to change(UserGpaHistory, :count).by(1)

        expect(response.status).to eq(200)
        expect(json["user_classes"]).to_not be_nil
      end

      it "returns 400 if there is an error creating a user_class" do
        expectation = expect {
          post :create, {:user_id => @user.id,
                         user_class: attributes_for(:user_class, name: nil)}
        }

        expectation.to change(UserClass, :count).by(0)
        expectation.to change(UserClassHistory, :count).by(0)
        expectation.to change(UserGpaHistory, :count).by(0)

        expect(response.status).to eq(400)
        expect(json["user_classes"]).to be_empty
      end
    end

  end

  describe "GET #history" do
    login_student

    it "returns all history records for the given class" do
      create(:user_class_history, user_class_id: 1)
      create(:user_class_history, user_class_id: 1)
      create(:user_class_history, user_class_id: 1)
      create(:user_class_history, user_class_id: 2)

      get :history, {:id => 1}

      expect(response.status).to eq(200)
      expect(json["class_history"].length).to eq(3)
    end
  end
end
