require 'rails_helper'

describe Api::V1::UserTagController do

  describe "GET #index" do
    describe "as an org admin" do
      login_org_admin

      let(:org)   { create(:organization, id: subject.current_user.organization_id) }
      let!(:student1) { create(:student, organization_id: org.id) }

      it "returns 200" do
        get :index, {:user_id => student1.id}
        expect(response.status).to eq(200)
      end

    end

    describe "as a mentor" do
      login_mentor

      let(:org)   { create(:organization, id: subject.current_user.organization_id) }
      let!(:student1) { create(:student, organization_id: org.id) }

      it "returns 200" do
        get :index, {:user_id => student1.id}
        expect(response.status).to eq(200)
      end

    end

    describe "as a student" do
      login_student

      let(:org)   { create(:organization, id: subject.current_user.organization_id) }
      let!(:student1) { create(:student, id: subject.current_user, organization_id: org.id) }

      it "returns 403" do
        get :index, {:user_id => student1.id}
        expect(response.status).to eq(403)
      end

    end
  end

  describe "POST #create" do
    describe "as an org admin" do
      login_org_admin

      let(:org)   { create(:organization, id: subject.current_user.organization_id) }
      let!(:student1) { create(:student, organization_id: org.id) }

      it "returns 200" do
        post :create, {:user_id => student1.id,
                       :tag => 'herroprease'}
        expect(response.status).to eq(200)
      end

    end

    describe "as a mentor" do
      login_mentor

      let(:org)   { create(:organization, id: subject.current_user.organization_id) }
      let!(:student1) { create(:student, organization_id: org.id) }

      it "returns 403" do
        post :create, {:user_id => student1.id,
                       :tag => 'herroprease'}
        expect(response.status).to eq(403)
      end

    end

    describe "as a student" do
      login_student

      let(:org)   { create(:organization, id: subject.current_user.organization_id) }
      let!(:student1) { create(:student, id: subject.current_user, organization_id: org.id) }

      it "returns 403" do
        post :create, {:user_id => student1.id,
                       :tag => 'herroprease'}
        expect(response.status).to eq(403)
      end

    end
  end

  describe "DELETE #destroy" do
    describe "as an org admin" do
      login_org_admin

      let(:org)   { create(:organization, id: subject.current_user.organization_id) }
      let!(:student1) { create(:student, organization_id: org.id) }

      it "returns 200" do
        delete :destroy, {:id => student1.id,
                       :tag => 'herroprease'}
        expect(response.status).to eq(200)
      end

    end

    describe "as a mentor" do
      login_mentor

      let(:org)   { create(:organization, id: subject.current_user.organization_id) }
      let!(:student1) { create(:student, organization_id: org.id) }

      it "returns 403" do
        delete :destroy, {:id => student1.id,
                       :tag => 'herroprease'}
        expect(response.status).to eq(403)
      end

    end

    describe "as a student" do
      login_student

      let(:org)   { create(:organization, id: subject.current_user.organization_id) }
      let!(:student1) { create(:student, id: subject.current_user, organization_id: org.id) }

      it "returns 403" do
        delete :destroy, {:id => student1.id,
                       :tag => 'herroprease'}
        expect(response.status).to eq(403)
      end

    end
  end

end
