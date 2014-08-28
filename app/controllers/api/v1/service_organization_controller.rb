class Api::V1::ServiceOrganizationController < ApplicationController
  respond_to :json

  before_filter :authenticate_user!
  skip_before_filter :verify_authenticity_token
  before_filter :load_services
  def load_services( userServiceOrganizationService=nil, userRepo=nil)
    @userServiceOrganizationService = userServiceOrganizationService ? userServiceOrganizationService : UserServiceOrganizationService.new
    @userRepository = userRepo ? userRepo : UserRepository.new
  end

  # GET /users/:id/service_organizations_hours?time_unit_id=#
  def user_service_organizations_hours
    userId = params[:id].to_i
    time_unit_id = params[:time_unit_id].to_i

    user = @userRepository.get_user(userId)
    if !can?(current_user, :manage_user_extracurricular_and_service, user)
      render status: :forbidden,
        json: {}
      return
    end

    organizations_result = @userServiceOrganizationService.get_user_service_organizations(userId)

    hours_result = @userServiceOrganizationService.get_user_service_hours(userId, time_unit_id)

    render status: :ok,
      json: {
        info: "User's Service Organizations and hours",
        user_service_organizations: organizations_result,
        user_service_hours: hours_result
      }
  end

  # POST /service_organization
  def add_user_service_organization
    new_service_organization = params[:user_service_organization]
    new_service_hour = params[:user_service_hour]
    userId = params[:user_service_organization][:user_id].to_i

    user = @userRepository.get_user(userId)
    if !can?(current_user, :manage_user_extracurricular_and_service, user)
      render status: :forbidden,
        json: {}
      return
    end

    resultOrg = @userServiceOrganizationService.save_user_service_organization(new_service_organization)
    new_service_hour[:user_service_organization_id] = resultOrg.object.id
    resultHour = @userServiceOrganizationService.save_user_service_hour(new_service_hour)

    render status: resultOrg.status,
      json: {
        info: [resultOrg.info, resultHour.info],
        user_service_organization: resultOrg.object,
        user_service_hour: resultHour.object
      }
  end

  # POST /service_hour
  def add_user_service_hour
    new_service_hour = params[:user_service_hour]
    userId = params[:user_service_hour][:user_id].to_i

    user = @userRepository.get_user(userId)
    if !can?(current_user, :manage_user_extracurricular_and_service, user)
      render status: :forbidden,
        json: {}
      return
    end

    result = @userServiceOrganizationService.save_user_service_hour(new_service_hour)

    render status: result.status,
      json: {
        info: result.info,
        user_service_hour: result.object
      }
  end

  # PUT /service_organization/:id
  def update_user_service_organization
    serviceOrganizationId = params[:id].to_i
    updated_service_organization = params[:user_service_organization]

    userServiceOrganization = @userServiceOrganizationService.get_user_service_organization(serviceOrganizationId)

    user = @userRepository.get_user(userServiceOrganization.user_id)
    if !can?(current_user, :manage_user_extracurricular_and_service, user)
      render status: :forbidden,
        json: {}
      return
    end

    result = @userServiceOrganizationService.update_user_service_organization(serviceOrganizationId, updated_service_organization)

    render status: result.status,
      json: {
        info: result.info,
        user_service_organization: result.object
      }
  end

  # PUT /service_hour/:id
  def update_user_service_hour
    serviceHourId = params[:id].to_i
    updated_service_hour = params[:user_service_hour]

    userServiceHour = @userServiceOrganizationService.get_user_service_hour(serviceHourId)

    user = @userRepository.get_user(userServiceHour.user_id)
    if !can?(current_user, :manage_user_extracurricular_and_service, user)
      render status: :forbidden,
        json: {}
      return
    end

    result = @userServiceOrganizationService.update_user_service_hour(serviceHourId, updated_service_hour)

    render status: result.status,
      json: {
        info: result.info,
        user_service_hour: result.object
      }
  end

  # DELETE /service_organization/:id?time_unit_id=#
  def delete_user_service_organization
    serviceOrganizationId = params[:id].to_i
    time_unit_id = params[:time_unit_id].to_i

    userServiceOrganization = @userServiceOrganizationService.get_user_service_organization(serviceOrganizationId)

    user = @userRepository.get_user(userServiceOrganization.user_id)
    if !can?(current_user, :manage_user_extracurricular_and_service, user)
      render status: :forbidden,
        json: {}
      return
    end

    result = @userServiceOrganizationService.delete_user_service_organization(serviceOrganizationId, userServiceOrganization.user_id, time_unit_id)

    render status: result.status,
      json: {
        info: result.info
      }
  end

  # DELETE /service_hour/:id
  def delete_user_service_hour
    serviceHourId = params[:id].to_i

    userServiceHour = @userServiceOrganizationService.get_user_service_hour(serviceHourId)

    user = @userRepository.get_user(userServiceHour.user_id)
    if !can?(current_user, :manage_user_extracurricular_and_service, user)
      render status: :forbidden,
        json: {}
      return
    end

    result = @userServiceOrganizationService.delete_user_service_hour(serviceHourId)

    render status: result.status,
      json: {
        info: result.info
      }
  end

end
