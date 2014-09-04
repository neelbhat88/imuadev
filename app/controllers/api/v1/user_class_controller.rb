class Api::V1::UserClassController < ApplicationController
  respond_to :json

  before_filter :authenticate_user!
  skip_before_filter :verify_authenticity_token

  before_filter :load_services

  def load_services( userClassService=nil, userRepo=nil, userClassHistoryService=nil )
    @userClassService = userClassService ? userClassService : UserClassService.new
    @userRepository = userRepo ? userRepo : UserRepository.new
    @userClassHistoryService = userClassHistoryService ? userClassHistoryService : UserClassHistoryService.new
  end

  # GET /users/:user_id/user_class?time_unit=#
  def index
    userId = params[:user_id].to_i
    time_unit_id = params[:time_unit].to_i

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

    classes = @userClassService.get_user_classes(userId, time_unit_id)

    render status: :ok,
      json: {
        info: "User's academics data",
        user_classes: classes.map{|uc| ViewUserClass.new(uc)}
      }
  end

  # POST /users/:user_id/user_class
  def create
    userId = params[:user_id]
    new_class = params[:user_class]

    result = @userClassService.save_user_class(current_user, userId, new_class)

    view_user_class = ViewUserClass.new(result.object) unless result.object.nil?
    render status: result.status,
      json: {
        info: result.info,
        user_class: view_user_class
      }
  end

  # PUT /user_class/:id
  def update
    classId = params[:id]
    updated_class = params[:user_class]

    user_class = @userClassService.update_user_class(current_user, classId, updated_class)

    if user_class.nil?
      render status: :bad_request,
      json: {
        info: "Failed to update user class"
      }
      return
    end

    view_user_class = ViewUserClass.new(user_class)
    render status: :ok,
      json: {
        info: "Updated user class",
        user_class: view_user_class
      }
  end

  # DELETE /user_class/:id
  def destroy
    classId = params[:id].to_i

    if @userClassService.delete_user_class(classId)
      render status: :ok,
        json: {
          info: "Deleted User Class"
        }
      return
    else
      render status: :internal_server_error,
        json: {
          info: "Failed to delete user class"
        }
      return
    end
  end

  # GET /user_class/:id/history
  def history
    classId = params[:id].to_i

    class_history = @userClassHistoryService.get_history_for_class(classId)

    render status: :ok,
      json: {
        info: "History for class",
        class_history: class_history
      }
  end
end
