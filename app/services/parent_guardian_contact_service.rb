class ParentGuardianContactService

  def get_parent_guardian_contact(parentGuardianContactId)
    return ParentGuardianContact.where(:id => parentGuardianContactId).first
  end

  def get_parent_guardian_contacts(userId)
    return ParentGuardianContact.where(:user_id => userId)
  end

  def create_parent_guardian_contact(parentGuardianContact)
    newParentGuardianContact = ParentGuardianContact.new do | c |
      c.user_id      = parentGuardianContact[:user_id]
      c.name         = parentGuardianContact[:name]
      c.relationship = parentGuardianContact[:relationship]
      c.email        = parentGuardianContact[:email]
      c.phone        = parentGuardianContact[:phone]
    end

    if !newParentGuardianContact.valid?
    end

    if newParentGuardianContact.save
      return ReturnObject.new(:ok, "Successfully created ParentGuardianContact, id: #{newParentGuardianContact.id}", newParentGuardianContact)
    else
      return ReturnObject.new(:internal_server_error, "Failed to create ParentGuardianContact. Errors: #{newParentGuardianContact.errors.inspect}", nil)
    end
  end

  def update_parent_guardian_contact(parentGuardianContactId, parentGuardianContact)
    dbParentGuardianContact = get_parent_guardian_contact(parentGuardianContactId)

    if dbParentGuardianContact.nil?
      return ReturnObject.new(:internal_server_error, "Failed to find ParentGuardianContact with id: #{parentGuardianContactId}", nil)
    end

    if dbParentGuardianContact.update_attributes(:name         => parentGuardianContact[:name],
                                                 :relationship => parentGuardianContact[:relationship],
                                                 :email        => parentGuardianContact[:email],
                                                 :phone        => parentGuardianContact[:phone])
      return ReturnObject.new(:ok, "Successfully updated ParentGuardianContact, id: #{dbParentGuardianContact.id}.", dbParentGuardianContact)
    else
      return ReturnObject.new(:internal_server_error, "Failed to update ParentGuardianContact, id: #{dbParentGuardianContact.id}. Errors: #{dbParentGuardianContact.errors.inspect}", nil)
    end
  end

  def delete_parent_guardian_contact(parentGuardianContactId)
    dbParentGuardianContact = get_parent_guardian_contact(parentGuardianContactId)

    if dbParentGuardianContact.nil?
      return ReturnObject.new(:internal_server_error, "Failed to find ParentGuardianContact with id: #{parentGuardianContactId}.", nil)
    end

    if dbParentGuardianContact.destroy()
      return ReturnObject.new(:ok, "Successfully deleted ParentGuardianContact, id: #{dbParentGuardianContact.id}.", nil)
    else
      return ReturnObject.new(:internal_server_error, "Failed to delete ParentGuardianContact, id: #{dbParentGuardianContact.id}. Errors: #{dbParentGuardianContact.errors.inspect}", nil)
    end
  end

end
