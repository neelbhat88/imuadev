class Api::V1::ServiceActivityController < ApplicationController
  respond_to :json

  before_filter :authenticate_user!
  skip_before_filter :verify_authenticity_token
  before_filter :load_services
  def load_services( userServiceActivityService=nil, userRepo=nil)
    @userServiceActivityService = userServiceActivityService ? userServiceActivityService : UserServiceActivityService.new
    @userRepository = userRepo ? userRepo : UserRepository.new
  end

  # GET /users/:id/service_activity_events?time_unit_id=#
  def user_service_activity_events
    userId = params[:id].to_i
    time_unit_id = params[:time_unit_id].to_i

    user = @userRepository.get_user(userId)
    if !can?(current_user, :manage_user_events, user)
      render status: :forbidden,
        json: {}
      return
    elsif !can?(current_user, :manage_user_activities, user)
      render status: :forbidden,
        json: {}
      return
    end

    activities_result = @userServiceActivityService.get_user_service_activities(userId)

    events_result = @userServiceActivityService.get_user_service_activity_events(userId, time_unit_id)

    render status: :ok,
      json: {
        info: "User's Service Activities and Events",
        user_service_activities: activities_result,
        user_service_activity_events: events_result
      }
  end

  # POST /service_activity
  def add_user_service_activity
    new_service_activity = params[:service_activity]
    userId = params[:service_activity][:user_id].to_i

    user = @userRepository.get_user(userId)
    if !can?(current_user, :manage_user_activities, user)
      render status: :forbidden,
        json: {}
      return
    end

    result = @userServiceActivityService.save_user_service_activity(new_service_activity)

    render status: result.status,
      json: {
        info: result.info,
        user_service_activity: result.object
      }
  end

  # POST /service_activity_event
  def add_user_service_activity_event
    new_service_activity_event = params[:service_activity_event]
    userId = params[:service_activity_event][:user_id].to_i

    user = @userRepository.get_user(userId)
    if !can?(current_user, :manage_user_events, user)
      render status: :forbidden,
        json: {}
      return
    end

    result = @userServiceActivityService.save_user_service_activity_event(new_service_activity_event)

    render status: result.status,
      json: {
        info: result.info,
        user_service_activity_event: result.object
      }
  end

  # PUT /service_activity/:id
  def update_user_service_activity
    serviceActivityId = params[:id].to_i
    updated_service_activity = params[:service_activity]

    userServiceActivity = @userServiceActivityService.get_user_service_activity(serviceActivityId)

    user = @userRepository.get_user(userServiceActivity.user_id)
    if !can?(current_user, :manage_user_activities, user)
      render status: :forbidden,
        json: {}
      return
    end

    result = @userServiceActivityService.update_user_service_activity(serviceActivityId, updated_service_activity)

    render status: result.status,
      json: {
        info: result.info,
        user_service_activity: result.object
      }
  end

  # PUT /service_activity_event/:id
  def update_user_service_activity_event
    serviceActivityEventId = params[:id].to_i
    updated_service_activity_event = params[:service_activity_event]

    userServiceActivityEvent = @userServiceActivityService.get_user_service_activity_event(serviceActivityEventId)

    user = @userRepository.get_user(userServiceActivityEvent.user_id)
    if !can?(current_user, :manage_user_events, user)
      render status: :forbidden,
        json: {}
      return
    end

    result = @userServiceActivityService.update_user_service_activity_event(serviceActivityEventId, updated_service_activity_event)

    render status: result.status,
      json: {
        info: result.info,
        user_service_activity_event: result.object
      }
  end

  # DELETE /service_activity/:id
  def delete_user_service_activity
    serviceActivityId = params[:id].to_i

    userServiceActivity = @userServiceActivityService.get_user_service_activity(serviceActivityId)

    user = @userRepository.get_user(userServiceActivity.user_id)
    if !can?(current_user, :manage_user_activities, user)
      render status: :forbidden,
        json: {}
      return
    end

    result = @userServiceActivityService.delete_user_service_activity(serviceActivityId)

    render status: result.status,
      json: {
        info: result.info
      }
  end

  # DELETE /service_activity_event/:id
  def delete_user_service_activity_event
    serviceActivityEventId = params[:id].to_i

    userServiceActivityEvent = @userServiceActivityService.get_user_service_activity_event(serviceActivityEventId)

    user = @userRepository.get_user(userServiceActivityEvent.user_id)
    if !can?(current_user, :manage_user_events, user)
      render status: :forbidden,
        json: {}
      return
    end

    result = @userServiceActivityService.delete_user_service_activity_event(serviceActivityEventId)

    render status: result.status,
      json: {
        info: result.info
      }
  end

end
