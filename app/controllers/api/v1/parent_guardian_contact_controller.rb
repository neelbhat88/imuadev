class Api::V1::ParentGuardianContactController < ApplicationController
  respond_to :json

  before_filter :authenticate_token
  skip_before_filter :verify_authenticity_token
  before_filter :load_services

  def load_services( parentGuardianContactService = nil, userRepository = nil )
    @parentGuardianContactService = parentGuardianContactService ? parentGuardianContactService : ParentGuardianContactService.new
    @userRepository = userRepository ? userRepository : UserRepository.new
  end

  # GET /users/:id/parent_guardian_contacts
  def get_parent_guardian_contacts
    userId = params[:id].to_i

    user = @userRepository.get_user(userId)
    if !can?(current_user, :read_parent_guardian_contacts, user)
      render status: :forbidden, json: {}
      return
    end

    result = @parentGuardianContactService.get_parent_guardian_contacts(userId)

    render status: :ok,
      json: {
        info: "All parent_guardian_contacts",
        parent_guardian_contacts: result
      }
  end

  # POST /users/:id/parent_guardian_contact
  def create_parent_guardian_contact
    parentGuardianContact = params[:parent_guardian_contact]
    userId                = params[:id].to_i

    user = @userRepository.get_user(userId)
    if !can?(current_user, :manage_parent_guardian_contacts, user)
      render status: :forbidden, json: {}
      return
    end

    parentGuardianContact[:user_id] = userId
    result = @parentGuardianContactService.create_parent_guardian_contact(parentGuardianContact)

    render status: result.status,
      json: {
        info: result.info,
        parent_guardian_contact: result.object
      }
  end

  # PUT /parent_guardian_contact/:id
  def update_parent_guardian_contact
    parentGuardianContactId      = params[:id].to_i
    updatedParentGuardianContact = params[:parent_guardian_contact]

    parentGuardianContact = @parentGuardianContactService.get_parent_guardian_contact(parentGuardianContactId)
    user = @userRepository.get_user(parentGuardianContact.user_id)
    if !can?(current_user, :manage_parent_guardian_contacts, user)
      render status: :forbidden, json: {}
      return
    end

    result = @parentGuardianContactService.update_parent_guardian_contact(parentGuardianContactId, updatedParentGuardianContact)

    render status: result.status,
      json: {
        info: result.info,
        parent_guardian_contact: result.object
      }
  end

  # DELETE /parent_guardian_contact/:id
  def delete_parent_guardian_contact
    parentGuardianContactId = params[:id].to_i

    parentGuardianContact = @parentGuardianContactService.get_parent_guardian_contact(parentGuardianContactId)
    user = @userRepository.get_user(parentGuardianContact.user_id)
    if !can?(current_user, :manage_parent_guardian_contacts, user)
      render status: :forbidden, json: {}
      return
    end

    result = @parentGuardianContactService.delete_parent_guardian_contact(parentGuardianContactId)

    render status: result.status,
      json: {
        info: result.info,
      }
  end

end
