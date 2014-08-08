require 'rails_helper'

describe Api::V1::ParentGuardianContactController do

  describe "GET /users/:id/parent_guardian_contacts" do

    describe "as a super admin" do
      login_super_admin

      let!(:student) { create(:student) }
      let!(:parent_guardian_contact_1) { create(:parent_guardian_contact, user_id: student.id) }
      let!(:parent_guardian_contact_2) { create(:parent_guardian_contact, user_id: student.id) }

      it "returns 200 when requesting all parent guardian contacts." do
        get :get_parent_guardian_contacts, {:id => student.id}
        expect(response.status).to eq(200)
        expect(json["parentGuardianContacts"].length).to eq(2)
      end
    end
  end

  describe "GET /parent_guardian_contact/:id" do

    describe "as a super admin" do
      login_super_admin

      let!(:student) { create(:student) }
      let!(:parent_guardian_contact) { create(:parent_guardian_contact, user_id: student.id) }

      it "returns 200 when requesting a parent guardian contact." do
        get :get_parent_guardian_contact, {:id => parent_guardian_contact.id}
        expect(response.status).to eq(200)
        expect(json["parentGuardianContact"]["id"]).to eq(parent_guardian_contact.id)
      end
    end

  end

  describe "POST /parent_guardian_contact" do

    describe "as a super admin" do
      login_super_admin

      let!(:student) { create(:student) }

      it "returns 200 when creating a parent guardian contact." do
        parentGuardianContact = attributes_for(:parent_guardian_contact, user_id: student.id)
        post :create_parent_guardian_contact, {:parent_guardian_contact => parentGuardianContact}
        expect(response.status).to eq(200)
        expect(json["parentGuardianContact"]["user_id"]).to eq(student.id)
      end
    end

  end

  describe "PUT /parent_guardian_contact/:id" do

  end

  describe "DELETE /parent_guardian_contact/:id" do

  end

end
