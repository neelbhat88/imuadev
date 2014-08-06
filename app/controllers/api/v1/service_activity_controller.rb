class Api::V1::ServiceActivityController < ApplicationController
  respond_to :json

  before_filter :authenticate_user!
  skip_before_filter :verify_authenticity_token
  before_filter :load_services
  def load_services( userServiceActivityService=nil, userRepo=nil)
    @userServiceActivityService = userServiceActivityService ? userServiceActivityService : UserServiceActivityService.new
    @userRepository = userRepo ? userRepo : UserRepository.new
  end

  # GET /user/:id/service_activity_events?time_unit_id=#
  def user_service_activity_events
    userId = params[:id].to_i
    time_unit_id = params[:time_unit_id].to_i

    if !student_can_access?(userId)
      render status: :forbidden,
        json: {}

      return
    end

    user = @userRepository.get_user(userId)
    if !same_organization?(user.organization_id)
      render status: :forbidden,
        json: {}

      return
    end

    service_activities = @userServiceActivityService.get_user_service_activities(userId)

    service_events = @userServiceActivityService.get_user_service_activity_events(userId, time_unit_id)

    render status: :ok,
      json: {
        info: "User's Service Activities and Events",
        user_service_activities: service_activities,
        user_service_activity_events: service_events
      }
  end

  # POST /service_activity
  def add_user_service_activity
    new_service_activity = params[:service_activity]


    user_service_activity = @userServiceActivityService.save_user_service_activity(new_service_activity)

    if user_service_activity.nil?
      render status: :bad_request,
      json: {
        info: "Failed to create a user service activity."
      }
      return
    end

    render status: :ok,
      json: {
        info: "Saved user service activity",
        user_service_activity: user_service_activity
      }
  end

  # POST /service_activity_event
  def add_user_service_activity_event
    new_service_activity_event = params[:service_activity_event]


    user_service_activity_event = @userServiceActivityService.save_user_service_activity_event(new_service_activity_event)

    if user_service_activity_event.nil?
      render status: :bad_request,
      json: {
        info: "Failed to create a user service activity event."
      }
      return
    end

    render status: :ok,
      json: {
        info: "Saved user service activity event",
        user_service_activity_event: user_service_activity_event
      }
  end

  # PUT /service_activity/:id
  def update_user_service_activity
    serviceActivityId = params[:id].to_i
    updated_service_activity = params[:service_activity]

    user_service_activity = @userServiceActivityService.update_user_service_activity(serviceActivityId, updated_service_activity)

    if user_service_activity.nil?
      render status: :bad_request,
      json: {
        info: "Failed to update user service activity"
      }
      return
    end

    render status: :ok,
      json: {
        info: "Updated user service activity",
        user_service_activity: user_service_activity
      }
  end

  # PUT /service_activity_event/:id
  def update_user_service_activity_event
    serviceActivityEventId = params[:id].to_i
    updated_service_activity_event = params[:service_activity_event]

    user_service_activity_event = @userServiceActivityService.update_user_service_activity_event(serviceActivityEventId, updated_service_activity_event)

    if user_service_activity_event.nil?
      render status: :bad_request,
      json: {
        info: "Failed to update user service activity"
      }
      return
    end

    render status: :ok,
      json: {
        info: "Updated user service activity",
        user_service_activity_event: user_service_activity_event
      }
  end

  # DELETE /service_activity/:id
  def delete_user_service_activity
    serviceActivityId = params[:id].to_i

    if @userServiceActivityService.delete_user_service_activity(serviceActivityId)
      render status: :ok,
        json: {
          info: "Deleted User Service Activity"
        }
      return
    else
      render status: :internal_server_error,
        json: {
          info: "Failed to delete user service activity"
        }
      return
    end
  end

  # DELETE /service_activity_event/:id
  def delete_user_service_activity_event
    serviceActivityEventId = params[:id].to_i

    if @userServiceActivityService.delete_user_service_activity_event(serviceActivityEventId)
      render status: :ok,
        json: {
          info: "Deleted User Service Activity Event"
        }
      return
    else
      render status: :internal_server_error,
        json: {
          info: "Failed to delete user service activity event"
        }
      return
    end
  end

end
