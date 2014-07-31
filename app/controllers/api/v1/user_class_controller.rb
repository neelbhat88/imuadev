class Api::V1::UserClassController < ApplicationController
  respond_to :json

  before_filter :authenticate_user!
  skip_before_filter :verify_authenticity_token

  before_filter :load_services

  def load_services( userClassService=nil, userRepo=nil )
    @userClassService = userClassService ? userClassService : UserClassService.new
    @userRepository = userRepo ? userRepo : UserRepository.new
  end

  # GET /user/:user_id/user_class?time_unit=#
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
        user_classes: classes
      }
  end

  # POST /user/:user_id/user_class
  def create
    userId = params[:user_id]
    new_class = params[:user_class]

    user_class = @userClassService.save_user_class(userId, new_class)

    if user_class.nil?
      render status: :bad_request,
      json: {
        info: "Failed to create a user class."
      }
      return
    end

    render status: :ok,
      json: {
        info: "Saved user class",
        user_class: user_class
      }
  end

  # PUT /user/:id/classes/:class_id
  def update_user_class
    userId = params[:id]
    classId = params[:class_id]
    updated_class = params[:user_class]

    user_class = @userClassService.update_user_class(updated_class)

    if user_class.nil?
      render status: :bad_request,
      json: {
        info: "Failed to update user class"
      }
      return
    end

    render status: :ok,
      json: {
        info: "Updated user class",
        user_class: user_class
      }
  end

  # DELETE /user/:id/classes/:class_id
  def delete_user_class
    userId = params[:id].to_i
    classId = params[:class_id].to_i

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
end
