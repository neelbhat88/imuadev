require 'rails_helper'

describe Api::V1::ParentGuardianContactController do

  describe "GET /users/:id/parent_guardian_contacts" do

    describe "as a super admin" do
      login_super_admin

      let!(:student) { create(:student) }
      let!(:parentGuardianContact1) { create(:parent_guardian_contact, user_id: student.id) }
      let!(:parentGuardianContact2) { create(:parent_guardian_contact, user_id: student.id) }

      it "returns 200 when requesting all parent guardian contacts." do
        get :get_parent_guardian_contacts, {:id => student.id}
        expect(response.status).to eq(200)
        expect(json["parent_guardian_contacts"].length).to eq(2)
      end
    end
  end

  describe "POST /parent_guardian_contact" do

    describe "as a super admin" do
      login_super_admin

      let!(:student) { create(:student) }

      it "returns 200 when creating a parent guardian contact." do
        parentGuardianContact = attributes_for(:parent_guardian_contact, user_id: student.id + 1)
        post :create_parent_guardian_contact, {:id => student.id, :parent_guardian_contact => parentGuardianContact}
        expect(response.status).to eq(200)
        expect(json["parent_guardian_contact"]["user_id"]).to eq(student.id)
      end
    end
  end

  describe "PUT /parent_guardian_contact/:id" do

    describe "as a super admin" do
      login_super_admin

      let!(:student) { create(:student) }
      let!(:parentGuardianContact) { create(:parent_guardian_contact, user_id: student.id) }

      it "returns 200 when updating a parent guardian contact." do
        updatedParentGuardianContact = attributes_for(:parent_guardian_contact, id: parentGuardianContact.id + 1,
                                                                                user_id: student.id + 1,
                                                                                name: "Updated Name",
                                                                                relationship: "Updated Relationship",
                                                                                email: "Updated@email.com",
                                                                                phone: "444-444-4444")
        put :update_parent_guardian_contact, {:id => parentGuardianContact.id,
                                              :parent_guardian_contact => updatedParentGuardianContact}
        expect(response.status).to eq(200)
        expect(json["parent_guardian_contact"]["id"]).to eq(parentGuardianContact.id)
        expect(json["parent_guardian_contact"]["user_id"]).to eq(student.id)
        expect(json["parent_guardian_contact"]["name"]).to eq("Updated Name")
        expect(json["parent_guardian_contact"]["relationship"]).to eq("Updated Relationship")
        expect(json["parent_guardian_contact"]["email"]).to eq("Updated@email.com")
        expect(json["parent_guardian_contact"]["phone"]).to eq("444-444-4444")
      end
    end
  end

  describe "DELETE /parent_guardian_contact/:id" do

    describe "as a super admin" do
      login_super_admin

      let!(:student) { create(:student) }
      let!(:parentGuardianContact) { create(:parent_guardian_contact, user_id: student.id) }

      it "returns 200 when deleting a parent guardian contact." do
        delete :delete_parent_guardian_contact, {:id => parentGuardianContact.id}
        expect(response.status).to eq(200)
      end
    end
  end

end
