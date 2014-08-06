class Api::V1::ExtracurricularActivityController < ApplicationController
  respond_to :json

  before_filter :authenticate_user!
  skip_before_filter :verify_authenticity_token
  before_filter :load_services
  def load_services( userExtracurricularActivityService=nil, userRepo=nil)
    @userExtracurricularActivityService = userExtracurricularActivityService ? userExtracurricularActivityService : UserExtracurricularActivityService.new
    @userRepository = userRepo ? userRepo : UserRepository.new
  end

  # GET /user/:id/extracurricular_activity_events?time_unit_id=#
  def user_extracurricular_activity_events
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

    extracurricular_activities = @userExtracurricularActivityService.get_user_extracurricular_activities(userId)

    extracurricular_events = @userExtracurricularActivityService.get_user_extracurricular_activity_events(userId, time_unit_id)

    render status: :ok,
      json: {
        info: "User's Extracurricular Activities and Events",
        user_extracurricular_activities: extracurricular_activities,
        user_extracurricular_activity_events: extracurricular_events
      }
  end

  # POST /extracurricular_activity
  def add_user_extracurricular_activity
    new_extracurricular_activity = params[:extracurricular_activity]


    user_extracurricular_activity = @userExtracurricularActivityService.save_user_extracurricular_activity(new_extracurricular_activity)

    if user_extracurricular_activity.nil?
      render status: :bad_request,
      json: {
        info: "Failed to create a user extracurricular activity."
      }
      return
    end

    render status: :ok,
      json: {
        info: "Saved user extracurricular activity",
        user_extracurricular_activity: user_extracurricular_activity
      }
  end

  # POST /extracurricular_activity_event
  def add_user_extracurricular_activity_event
    new_extracurricular_activity_event = params[:extracurricular_activity_event]


    user_extracurricular_activity_event = @userExtracurricularActivityService.save_user_extracurricular_activity_event(new_extracurricular_activity_event)

    if user_extracurricular_activity_event.nil?
      render status: :bad_request,
      json: {
        info: "Failed to create a user extracurricular activity event."
      }
      return
    end

    render status: :ok,
      json: {
        info: "Saved user extracurricular activity event",
        user_extracurricular_activity_event: user_extracurricular_activity_event
      }
  end

  # PUT /extracurricular_activity/:id
  def update_user_extracurricular_activity
    extracurricularActivityId = params[:id].to_i
    updated_extracurricular_activity = params[:extracurricular_activity]

    user_extracurricular_activity = @userExtracurricularActivityService.update_user_extracurricular_activity(extracurricularActivityId, updated_extracurricular_activity)

    if user_extracurricular_activity.nil?
      render status: :bad_request,
      json: {
        info: "Failed to update user extracurricular activity"
      }
      return
    end

    render status: :ok,
      json: {
        info: "Updated user extracurricular activity",
        user_extracurricular_activity: user_extracurricular_activity
      }
  end

  # PUT /extracurricular_activity_event/:id
  def update_user_extracurricular_activity_event
    extracurricularActivityEventId = params[:id].to_i
    updated_extracurricular_activity_event = params[:extracurricular_activity_event]

    user_extracurricular_activity_event = @userExtracurricularActivityService.update_user_extracurricular_activity_event(extracurricularActivityEventId, updated_extracurricular_activity_event)

    if user_extracurricular_activity_event.nil?
      render status: :bad_request,
      json: {
        info: "Failed to update user extracurricular activity"
      }
      return
    end

    render status: :ok,
      json: {
        info: "Updated user extracurricular activity",
        user_extracurricular_activity_event: user_extracurricular_activity_event
      }
  end

  # DELETE /extracurricular_activity/:id
  def delete_user_extracurricular_activity
    extracurricularActivityId = params[:id].to_i

    if @userExtracurricularActivityService.delete_user_extracurricular_activity(extracurricularActivityId)
      render status: :ok,
        json: {
          info: "Deleted User Extracurricular Activity"
        }
      return
    else
      render status: :internal_server_error,
        json: {
          info: "Failed to delete user extracurricular activity"
        }
      return
    end
  end

  # DELETE /extracurricular_activity_event/:id
  def delete_user_extracurricular_activity_event
    extracurricularActivityEventId = params[:id].to_i

    if @userExtracurricularActivityService.delete_user_extracurricular_activity_event(extracurricularActivityEventId)
      render status: :ok,
        json: {
          info: "Deleted User Extracurricular Activity Event"
        }
      return
    else
      render status: :internal_server_error,
        json: {
          info: "Failed to delete user extracurricular activity event"
        }
      return
    end
  end

end
