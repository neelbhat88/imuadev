class Api::V1::UserClassController < ApplicationController
  respond_to :json

  before_filter :authenticate_user!
  skip_before_filter :verify_authenticity_token

  before_filter :load_services

  def load_services( userClassService=nil, userRepo=nil, userClassHistoryService=nil,
                     userGpaService=nil, userGpaHistoryService=nil )
    @userClassService = userClassService ? userClassService : UserClassService.new
    @userRepository = userRepo ? userRepo : UserRepository.new
    @userClassHistoryService = userClassHistoryService ? userClassHistoryService : UserClassHistoryService.new
    @userGpaService = userGpaService ? userGpaService : UserGpaService.new
    @userGpaHistoryService = userGpaHistoryService ? userGpaHistoryService :
      UserGpaHistoryService.new
  end

  # GET /users/:user_id/user_class?time_unit=#
  def index
    userId = params[:user_id].to_i
    time_unit_id = params[:time_unit].to_i

    user = @userRepository.get_user(userId)
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
    user_gpa = @userGpaService.get_user_gpa(userId, time_unit_id)
    user_gpa_history = @userGpaHistoryService.get_user_gpa_history(userId, time_unit_id)
    org_class_titles = @userClassService.get_org_class_titles(organization_id: user.organization_id)

    render status: :ok,
      json: {
        info: "User's academics data",
        user_classes: classes.map{|uc| ViewUserClass.new(uc)},
        user_gpa: user_gpa,
        user_gpa_history: user_gpa_history,
        org_class_titles: org_class_titles
      }
  end

  # POST /users/:user_id/user_class
  def create
    userId = params[:user_id]
    new_class = params[:user_class]
    new_class[:grade_value] = new_class[:grade_value].to_f


    result = @userClassService.save_user_class(current_user, userId, new_class)
    classes = @userClassService.get_user_classes(new_class[:user_id], new_class[:time_unit_id])
    user_gpa = @userGpaService.get_user_gpa(userId, new_class[:time_unit_id])

    render status: result.status,
      json: {
        info: result.info,
        user_classes: classes.map{|uc| ViewUserClass.new(uc)},
        user_gpa: user_gpa
      }
  end

  # PUT /user_class/:id
  def update
    classId = params[:id]
    updated_class = params[:user_class]
    updated_class[:grade_value] = updated_class[:grade_value].to_f

    user_class = @userClassService.update_user_class(current_user, classId, updated_class)

    if user_class.nil?
      render status: :bad_request,
      json: {
        info: "Failed to update user class"
      }
      return
    end

    classes = @userClassService.get_user_classes(user_class.user_id, user_class.time_unit_id)
    user_gpa = @userGpaService.get_user_gpa(user_class.user_id, user_class.time_unit_id)

    render status: :ok,
      json: {
        info: "Updated user class",
        user_classes: classes.map{|uc| ViewUserClass.new(uc)},
        user_gpa: user_gpa
      }
  end

  # DELETE /user_class/:id
  def destroy
    classId = params[:id].to_i

    deleted_class = @userClassService.delete_user_class(classId)
    if deleted_class[:status]
      render status: :ok,
        json: {
          info: "Deleted User Class",
          user_gpa: deleted_class[:user_gpa]
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
