class Api::V1::UserServiceHourController< ApplicationController
  respond_to :json

  before_filter :load_services
  
  def load_services( userServiceOrganizationService=nil, userRepo=nil)
    @userServiceOrganizationService = userServiceOrganizationService ? userServiceOrganizationService : UserServiceOrganizationService.new
    @userRepository = userRepo ? userRepo : UserRepository.new
  end

  # Handled in parent controller currently
  # GET /users/:user_id/user_service_hour?time_unit_id=#
  def index
    userId = params[:id].to_i
    time_unit_id = params[:time_unit_id].to_i

    user = @userRepository.get_user(userId)
    if !can?(current_user, :manage_user_extracurricular_and_service, user)
      render status: :forbidden,
        json: {}
      return
    end

    user_service_hours = @userServiceOrganizationService.get_user_service_hours(userId, time_unit_id)

    render status: :ok,
      json: {
        info: "User's Service Hours",
        user_service_hours: user_service_hours
      }
  end

  # POST users/:user_id/user_service_hour
  def create
    new_service_hour = params[:user_service_hour]
    userId = params[:user_id].to_i

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

  # PUT /user_service_hour/:id
  def update
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

  # DELETE /user_service_hour/:id
  def destroy
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
