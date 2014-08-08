class Api::V1::ExtracurricularActivityController < ApplicationController
  respond_to :json

  before_filter :authenticate_user!
  skip_before_filter :verify_authenticity_token
  before_filter :load_services
  def load_services( userExtracurricularActivityService=nil, userRepo=nil)
    @userExtracurricularActivityService = userExtracurricularActivityService ? userExtracurricularActivityService : UserExtracurricularActivityService.new
    @userRepository = userRepo ? userRepo : UserRepository.new
  end

  # GET /users/:id/extracurricular_activity_events?time_unit_id=#
  def user_extracurricular_activity_events
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

    activities_result = @userExtracurricularActivityService.get_user_extracurricular_activities(userId)

    events_result = @userExtracurricularActivityService.get_user_extracurricular_activity_events(userId, time_unit_id)

    render status: :ok,
      json: {
        info: "User's Extracurricular Activities and Events",
        user_extracurricular_activities: activities_result,
        user_extracurricular_activity_events: events_result
      }
  end

  # POST /extracurricular_activity
  def add_user_extracurricular_activity
    new_extracurricular_activity = params[:user_extracurricular_activity]
    userId = params[:user_extracurricular_activity][:user_id].to_i

    user = @userRepository.get_user(userId)
    if !can?(current_user, :manage_user_activities, user)
      render status: :forbidden,
        json: {}
      return
    end

    result = @userExtracurricularActivityService.save_user_extracurricular_activity(new_extracurricular_activity)

    render status: result.status,
      json: {
        info: result.info,
        user_extracurricular_activity: result.object
      }
  end

  # POST /extracurricular_activity_event
  def add_user_extracurricular_activity_event
    new_extracurricular_activity_event = params[:user_extracurricular_activity_event]
    userId = params[:user_extracurricular_activity_event][:user_id].to_i

    user = @userRepository.get_user(userId)
    if !can?(current_user, :manage_user_events, user)
      render status: :forbidden,
        json: {}
      return
    end

    result = @userExtracurricularActivityService.save_user_extracurricular_activity_event(new_extracurricular_activity_event)

    render status: result.status,
      json: {
        info: result.info,
        user_extracurricular_activity_event: result.object
      }
  end

  # PUT /extracurricular_activity/:id
  def update_user_extracurricular_activity
    extracurricularActivityId = params[:id].to_i
    updated_extracurricular_activity = params[:user_extracurricular_activity]

    user_extracurricular_activity = @userExtracurricularActivityService.get_user_extracurricular_activity(extracurricularActivityId)

    user = @userRepository.get_user(user_extracurricular_activity.user_id)
    if !can?(current_user, :manage_user_activities, user)
      render status: :forbidden,
        json: {}
      return
    end

    result = @userExtracurricularActivityService.update_user_extracurricular_activity(extracurricularActivityId, updated_extracurricular_activity)

    render status: result.status,
      json: {
        info: result.info,
        user_extracurricular_activity: result.object
      }
  end

  # PUT /extracurricular_activity_event/:id
  def update_user_extracurricular_activity_event
    extracurricularActivityEventId = params[:id].to_i
    updated_extracurricular_activity_event = params[:user_extracurricular_activity_event]

    user_extracurricular_activity_event = @userExtracurricularActivityService.get_user_extracurricular_activity_event(extracurricularActivityEventId)

    user = @userRepository.get_user(user_extracurricular_activity_event.user_id)
    if !can?(current_user, :manage_user_events, user)
      render status: :forbidden,
        json: {}
      return
    end

    result = @userExtracurricularActivityService.update_user_extracurricular_activity_event(extracurricularActivityEventId, updated_extracurricular_activity_event)

    render status: result.status,
      json: {
        info: result.info,
        user_extracurricular_activity_event: result.object
      }
  end

  # DELETE /extracurricular_activity/:id
  def delete_user_extracurricular_activity
    extracurricularActivityId = params[:id].to_i

    user_extracurricular_activity = @userExtracurricularActivityService.get_user_extracurricular_activity(extracurricularActivityId)

    user = @userRepository.get_user(user_extracurricular_activity.user_id)
    if !can?(current_user, :manage_user_activities, user)
      render status: :forbidden,
        json: {}
      return
    end

    result = @userExtracurricularActivityService.delete_user_extracurricular_activity(extracurricularActivityId)

    render status: result.status,
      json: {
        info: result.info
      }
  end

  # DELETE /extracurricular_activity_event/:id
  def delete_user_extracurricular_activity_event
    extracurricularActivityEventId = params[:id].to_i

    user_extracurricular_activity_event = @userExtracurricularActivityService.get_user_extracurricular_activity_event(extracurricularActivityEventId)

    user = @userRepository.get_user(user_extracurricular_activity_event.user_id)
    if !can?(current_user, :manage_user_events, user)
      render status: :forbidden,
        json: {}
      return
    end

    result = @userExtracurricularActivityService.delete_user_extracurricular_activity_event(extracurricularActivityEventId)

    render status: result.status,
      json: {
        info: result.info
      }
  end

end
