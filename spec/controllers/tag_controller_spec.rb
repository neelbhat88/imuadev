require 'rails_helper'

describe Api::V1::TagController do

  describe "GET #index" do
    describe "as an org admin" do
      login_org_admin

      let(:org) { create(:organization, id: subject.current_user.organization_id) }


      it "returns 200" do
        get :index, {:organization_id => org.id}
        expect(response.status).to eq(200)
      end

    end

    describe "as a mentor" do
      login_mentor

      let(:org) { create(:organization, id: subject.current_user.organization_id) }


      it "returns 200" do
        get :index, {:organization_id => org.id}
        expect(response.status).to eq(200)
      end

    end

    describe "as a student" do
      login_student

      let(:org) { create(:organization, id: subject.current_user.organization_id) }


      it "returns 403" do
        get :index, {:organization_id => org.id}
        expect(response.status).to eq(403)
      end

    end
  end

  describe "POST #add_users_tag" do
    describe "as an org admin" do
      login_org_admin

      let(:org)   { create(:organization, id: subject.current_user.organization_id) }
      let(:student1) { create(:student, organization_id: org.id) }
      let(:student2) { create(:student, organization_id: org.id) }

      it "returns 200" do
        user1 = attributes_for(:student, id: student1.id, organization_id: org.id)
        user2 = attributes_for(:student, id: student2.id, organization_id: org.id)

        users = [user1, user2]
        post :add_users_tag,  {:id => org.id,
                               :tag => 'wheredeyatdoe',
                               :users => users}
        expect(response.status).to eq(200)
      end

    end

    describe "as a mentor" do
      login_mentor

      let(:org)   { create(:organization, id: subject.current_user.organization_id) }
      let(:student1) { create(:student, organization_id: org.id) }
      let(:student2) { create(:student, organization_id: org.id) }

      it "returns 403" do
        user1 = attributes_for(:student, id: student1.id, organization_id: org.id)
        user2 = attributes_for(:student, id: student2.id, organization_id: org.id)

        users = [user1, user2]
        post :add_users_tag, { :id => org.id,
                               :tag => 'wheredeyatdoe',
                               :users => users}
        expect(response.status).to eq(403)
      end

    end

    describe "as a student" do
      login_student

      let(:org)   { create(:organization, id: subject.current_user.organization_id) }
      let(:student1) { create(:student, organization_id: org.id) }
      let(:student2) { create(:student, organization_id: org.id) }

      it "returns 403" do
        user1 = attributes_for(:student, id: student1.id, organization_id: org.id)
        user2 = attributes_for(:student, id: student2.id, organization_id: org.id)

        users = [user1, user2]
        post :add_users_tag, {:id => org.id,
                               :tag => 'wheredeyatdoe',
                               :users => users}
        expect(response.status).to eq(403)
      end

    end

  end

  describe "DELETE #delete_users_tag" do
    describe "as an org admin" do
      login_org_admin

      let(:org)   { create(:organization, id: subject.current_user.organization_id) }
      let(:student1) { create(:student, organization_id: org.id) }
      let(:student2) { create(:student, organization_id: org.id) }

      it "returns 200" do
        user1 = attributes_for(:student, id: student1.id, organization_id: org.id)
        user2 = attributes_for(:student, id: student2.id, organization_id: org.id)

        users = [user1, user2]
        delete :delete_users_tag,  {:id => org.id,
                               :tag => 'wheredeyatdoe',
                               :users => users}
        expect(response.status).to eq(200)
      end

    end

    describe "as a mentor" do
      login_mentor

      let(:org)   { create(:organization, id: subject.current_user.organization_id) }
      let(:student1) { create(:student, organization_id: org.id) }
      let(:student2) { create(:student, organization_id: org.id) }

      it "returns 403" do
        user1 = attributes_for(:student, id: student1.id, organization_id: org.id)
        user2 = attributes_for(:student, id: student2.id, organization_id: org.id)

        users = [user1, user2]
        delete :delete_users_tag, { :id => org.id,
                               :tag => 'wheredeyatdoe',
                               :users => users}
        expect(response.status).to eq(403)
      end

    end

    describe "as a student" do
      login_student

      let(:org)   { create(:organization, id: subject.current_user.organization_id) }
      let(:student1) { create(:student, organization_id: org.id) }
      let(:student2) { create(:student, organization_id: org.id) }

      it "returns 403" do
        user1 = attributes_for(:student, id: student1.id, organization_id: org.id)
        user2 = attributes_for(:student, id: student2.id, organization_id: org.id)

        users = [user1, user2]
        delete :delete_users_tag, {:id => org.id,
                               :tag => 'wheredeyatdoe',
                               :users => users}
        expect(response.status).to eq(403)
      end

    end

  end

end
