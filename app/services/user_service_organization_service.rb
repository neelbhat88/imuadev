class UserServiceOrganizationService

  def get_user_service_organizations(userId)
    return UserServiceOrganization.where(:user_id => userId).order(:id)
  end

  def get_user_service_hours(userId, time_unit_id)
    return UserServiceHour.where(:user_id => userId, :time_unit_id => time_unit_id).order(:id)
  end

  def get_user_service_hours_2(filters = {})
    userServiceHours = nil

    if !defined?(filters[:module]) || filters[:module] == Constants.Modules[:SERVICE]
      applicable_filters = FilterFactory.new.conditions(UserServiceHour.column_names.map(&:to_sym), filters)
      userServiceHours = UserServiceHour.find(:all, :conditions => applicable_filters)
    end

    return userServiceHours.map{|ush| DomainUserServiceHour.new(ush)} unless userServiceHours.nil?
  end

  def get_user_service_organization(serviceOrganizationId)
    return UserServiceOrganization.where(:id => serviceOrganizationId).first
  end

  def get_user_service_hour(serviceHourId)
    return UserServiceHour.where(:id => serviceHourId).first
  end

  def get_hours_for_organization(user_service_organization_id, userId)
    return UserServiceHour.where(:user_service_organization_id => user_service_organization_id, :user_id => userId)
  end

  def save_user_service_organization(user_service_organization)
    new_service_organization = UserServiceOrganization.new do | u |
      u.user_id = user_service_organization[:user_id]
      u.name = user_service_organization[:name]
      u.description = user_service_organization[:description]
    end

    if new_service_organization.save
      return ReturnObject.new(:ok, "Successfully created Service Organization, id: #{new_service_organization.id}", new_service_organization)
    else
      return ReturnObject.new(:internal_server_error, "Failed to create Service Organization. Errors: #{new_service_organization.errors.inspect}", nil)
    end
  end

  def save_user_service_hour(user_service_hour)
    new_service_hour = UserServiceHour.new do | u |
      u.user_id = user_service_hour[:user_id]
      u.date = user_service_hour[:date]
      u.description = user_service_hour[:description]
      u.hours = user_service_hour[:hours]
      u.user_service_organization_id = user_service_hour[:user_service_organization_id]
      u.time_unit_id = user_service_hour[:time_unit_id]
    end

    if new_service_hour.save
      return ReturnObject.new(:ok, "Successfully created Service Hour, id: #{new_service_hour.id}", new_service_hour)
    else
      return ReturnObject.new(:internal_server_error, "Failed to create Service Hour. Errors: #{new_service_hour.errors.inspect}", nil)
    end
  end

  def update_user_service_organization(serviceOrganizationId, user_service_organization)
    db_class = UserServiceOrganization.find(serviceOrganizationId)
    if db_class.update_attributes(:name => user_service_organization[:name], :description => user_service_organization[:description])
      return ReturnObject.new(:ok, "Successfully updated Service Organization, id: #{db_class.id}", db_class)
    else
      return ReturnObject.new(:internal_server_error, "Failed to update Service Organization. Errors: #{db_class.errors.inspect}", nil)
    end
  end

  def update_user_service_hour(serviceHourId, user_service_hour)
    db_class = UserServiceHour.find(serviceHourId)
    if db_class.update_attributes(:description => user_service_hour[:description], :date => user_service_hour[:date], :hours => user_service_hour[:hours])
      return ReturnObject.new(:ok, "Successfully updated Service Hour, id: #{db_class.id}", db_class)
    else
      return ReturnObject.new(:internal_server_error, "Failed to update Service Hour. Errors: #{db_class.errors.inspect}", nil)
    end
  end

  def delete_user_service_organization(serviceOrganizationId, userId, time_unit_id)
    hours = get_hours_for_organization(serviceOrganizationId, userId)

    hours.delete_if {| hr | hr.time_unit_id == time_unit_id}

    if hours[0].nil?
      if UserServiceOrganization.find(serviceOrganizationId).destroy()
        return ReturnObject.new(:ok, "Successfully deleted Service Organization, id: #{serviceOrganizationId}", nil)
      else
        return ReturnObject.new(:internal_server_error, "Failed to delete Service Organization. id: #{serviceOrganizationId}", nil)
      end
    else
      if UserServiceHour.destroy_all(:user_service_organization_id => serviceOrganizationId, :user_id => userId, :time_unit_id => time_unit_id)
        return ReturnObject.new(:ok, "Successfully deleted all Hours in this semester for Service Organization, id: #{serviceOrganizationId}", nil)
      else
        return ReturnObject.new(:internal_server_error, "Failed to delete Hours for Service Organization. id: #{serviceOrganizationId}", nil)
      end
    end
  end

  def delete_user_service_hour(serviceHourId)
    if UserServiceHour.find(serviceHourId).destroy()
      return ReturnObject.new(:ok, "Successfully deleted Service Hour, id: #{serviceHourId}", nil)
    else
      return ReturnObject.new(:internal_server_error, "Failed to delete Service Hour. id: #{serviceHourId}", nil)
    end
  end

end
