class Api::V1::UserExtracurricularActivityDetailController < ApplicationController
  respond_to :json

  before_filter :authenticate_token
  skip_before_filter :verify_authenticity_token
  before_filter :load_services
  def load_services( userExtracurricularActivityService=nil, userRepo=nil)
    @userExtracurricularActivityService = userExtracurricularActivityService ? userExtracurricularActivityService : UserExtracurricularActivityService.new
    @userRepository = userRepo ? userRepo : UserRepository.new
  end

  # Handled in parent controller currently
  # GET /users/:user_id/user_extracurricular_activity?time_unit_id=#
  def index
    userId = params[:id].to_i
    time_unit_id = params[:time_unit_id].to_i

    user = @userRepository.get_user(userId)
    if !can?(current_user, :manage_user_extracurricular_and_service, user)
      render status: :forbidden,
        json: {}
      return
    end

    user_extracurricular_details = @userExtracurricularActivityService.get_user_extracurricular_activity_details(userId, time_unit_id)

    render status: :ok,
      json: {
        info: "User's Extracurricular Activities and Details",
        user_extracurricular_details: user_extracurricular_details
      }
  end

  # Handled in parent controller currently
  # POST /users/:user_id/user_extracurricular_activity_detail
  def create
    new_extracurricular_activity_detail = params[:user_extracurricular_detail]
    userId = params[:user_extracurricular_detail][:user_id].to_i

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
        user_extracurricular_detail: result.object
      }
  end

  # PUT /user_extracurricular_activity_detail/:id
  def update
    extracurricularActivityDetailId = params[:id].to_i
    updated_extracurricular_activity_detail = params[:user_extracurricular_detail]

    user_extracurricular_activity_detail = @userExtracurricularActivityService.get_user_extracurricular_activity_detail(extracurricularActivityDetailId)

    user = @userRepository.get_user(user_extracurricular_activity_detail.user_id)
    if !can?(current_user, :manage_user_extracurricular_and_service, user)
      render status: :forbidden,
        json: {}
      return
    end

    result = @userExtracurricularActivityService.update_user_extracurricular_activity_detail(updated_extracurricular_activity_detail)

    render status: result.status,
      json: {
        info: result.info,
        user_extracurricular_detail: result.object
      }
  end

  # DELETE /user_extracurricular_activity_detail/:id
  def destroy
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

end
