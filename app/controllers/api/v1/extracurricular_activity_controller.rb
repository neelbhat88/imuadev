class Api::V1::ExtracurricularActivityController < ApplicationController
  respond_to :json

  before_filter :authenticate_user!
  skip_before_filter :verify_authenticity_token
  before_filter :load_services
  def load_services( userExtracurricularActivityService=nil, userRepo=nil)
    @userExtracurricularActivityService = userExtracurricularActivityService ? userExtracurricularActivityService : UserExtracurricularActivityService.new
    @userRepository = userRepo ? userRepo : UserRepository.new
  end

  # GET /users/:id/extracurricular_activity_details?time_unit_id=#
  def user_extracurricular_activity_details
    userId = params[:id].to_i
    time_unit_id = params[:time_unit_id].to_i

    user = @userRepository.get_user(userId)
    if !can?(current_user, :manage_user_extracurricular_and_service, user)
      render status: :forbidden,
        json: {}
      return
    elsif !can?(current_user, :manage_user_extracurricular_and_service, user)
      render status: :forbidden,
        json: {}
      return
    end

    activities_result = @userExtracurricularActivityService.get_user_extracurricular_activities(userId)

    details_result = @userExtracurricularActivityService.get_user_extracurricular_activity_details(userId, time_unit_id)

    render status: :ok,
      json: {
        info: "User's Extracurricular Activities and Details",
        user_extracurricular_activities: activities_result,
        user_extracurricular_activity_details: details_result
      }
  end

  # POST /extracurricular_activity
  def add_user_extracurricular_activity
    new_extracurricular_activity = params[:user_extracurricular_activity]
    userId = params[:user_extracurricular_activity][:user_id].to_i

    user = @userRepository.get_user(userId)
    if !can?(current_user, :manage_user_extracurricular_and_service, user)
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

  # POST /extracurricular_activity_detail
  def add_user_extracurricular_activity_detail
    new_extracurricular_activity_detail = params[:user_extracurricular_activity_detail]
    userId = params[:user_extracurricular_activity_detail][:user_id].to_i

    user = @userRepository.get_user(userId)
    if !can?(current_user, :manage_user_extracurricular_and_service, user)
      render status: :forbidden,
        json: {}
      return
    end

    result = @userExtracurricularActivityService.save_user_extracurricular_activity_detail(new_extracurricular_activity_detail)

    render status: result.status,
      json: {
        info: result.info,
        user_extracurricular_activity_detail: result.object
      }
  end

  # POST /extracurricular_activity_with_detail
  def add_user_extracurricular_activity_with_detail
    new_extracurricular_activity_detail = params[:user_extracurricular_activity_detail]
    new_extracurricular_activity = params[:user_extracurricular_activity]
    userId = params[:user_extracurricular_activity_detail][:user_id].to_i

    user = @userRepository.get_user(userId)
    if !can?(current_user, :manage_user_extracurricular_and_service, user)
      render status: :forbidden,
        json: {}
      return
    end

    resultActivity = @userExtracurricularActivityService.save_user_extracurricular_activity(new_extracurricular_activity)

    resultDetail = @userExtracurricularActivityService.save_user_extracurricular_activity_detail(new_extracurricular_activity_detail)

    render status: resultDetail.status,
      json: {
        info: [resultDetail.info, resultActivity.info],
        user_extracurricular_activity_detail: resultDetail.object,
        user_extracurricular_activity: resultActivity.object
      }
  end

  # PUT /extracurricular_activity/:id
  def update_user_extracurricular_activity
    extracurricularActivityId = params[:id].to_i
    updated_extracurricular_activity = params[:user_extracurricular_activity]

    user_extracurricular_activity = @userExtracurricularActivityService.get_user_extracurricular_activity(extracurricularActivityId)

    user = @userRepository.get_user(user_extracurricular_activity.user_id)
    if !can?(current_user, :manage_user_extracurricular_and_service, user)
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

  # PUT /extracurricular_activity_detail/:id
  def update_user_extracurricular_activity_detail
    extracurricularActivityDetailId = params[:id].to_i
    updated_extracurricular_activity_detail = params[:user_extracurricular_activity_detail]

    user_extracurricular_activity_detail = @userExtracurricularActivityService.get_user_extracurricular_activity_detail(extracurricularActivityDetailId)

    user = @userRepository.get_user(user_extracurricular_activity_detail.user_id)
    if !can?(current_user, :manage_user_extracurricular_and_service, user)
      render status: :forbidden,
        json: {}
      return
    end

    result = @userExtracurricularActivityService.update_user_extracurricular_activity_detail(extracurricularActivityDetailId, updated_extracurricular_activity_detail)

    render status: result.status,
      json: {
        info: result.info,
        user_extracurricular_activity_detail: result.object
      }
  end

  # PUT /extracurricular_activity_with_detail
  def update_user_extracurricular_activity_with_detail
    updated_extracurricular_activity_detail = params[:user_extracurricular_activity_detail]
    updated_extracurricular_activity = params[:user_extracurricular_activity]
    userId = params[:user_extracurricular_activity_detail][:user_id].to_i

    user_extracurricular_activity_detail = @userExtracurricularActivityService.get_user_extracurricular_activity_detail(extracurricularActivityDetailId)

    user = @userRepository.get_user(user_extracurricular_activity_detail.user_id)
    if !can?(current_user, :manage_user_extracurricular_and_service, user)
      render status: :forbidden,
        json: {}
      return
    end

    result = @userExtracurricularActivityService.update_user_extracurricular_activity_detail(extracurricularActivityDetailId, updated_extracurricular_activity_detail)

    render status: result.status,
      json: {
        info: result.info,
        user_extracurricular_activity_detail: result.object
      }
  end

  # DELETE /extracurricular_activity/:id
  def delete_user_extracurricular_activity
    extracurricularActivityId = params[:id].to_i

    user_extracurricular_activity = @userExtracurricularActivityService.get_user_extracurricular_activity(extracurricularActivityId)

    user = @userRepository.get_user(user_extracurricular_activity.user_id)
    if !can?(current_user, :manage_user_extracurricular_and_service, user)
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

  # DELETE /extracurricular_activity_detail/:id
  def delete_user_extracurricular_activity_detail
    extracurricularActivityDetailId = params[:id].to_i

    user_extracurricular_activity_detail = @userExtracurricularActivityService.get_user_extracurricular_activity_detail(extracurricularActivityDetailId)

    user = @userRepository.get_user(user_extracurricular_activity_detail.user_id)
    if !can?(current_user, :manage_user_extracurricular_and_service, user)
      render status: :forbidden,
        json: {}
      return
    end

    result = @userExtracurricularActivityService.delete_user_extracurricular_activity_detail(extracurricularActivityDetailId)

    render status: result.status,
      json: {
        info: result.info
      }
  end

  # XXX: QUICK FIX to update activity ids
  # GET /extracurricular_activity/update_time_unit_id

  def update_time_unit_id
    UserExtracurricularActivity.all.each do | a |
      a.update_attributes(:time_unit_id => a.user_extracurricular_activity_details.first.time_unit_id)
    end

    render status: :ok,
      json: {
        info: "Updated activities"
    }
  end

end
