class Api::V1::ProgressController < ApplicationController

  before_filter :authenticate_user!
  skip_before_filter  :verify_authenticity_token

  respond_to :json

  # GET /user/:id/time_unit/:time_unit_id/progress
  # Returns All modules for a given semester and the
  # total points avaiable in each module and the user's points earned
  def all_modules_progress
    userId = params[:id]
    time_unit_id = params[:time_unit_id]

    result = ProgressService.new.get_all_progress(userId, time_unit_id)

    render status: result.status,
      json: {
        info: result.info,
        modules_progress: result.object
      }
  end

  # get /user/:id/time_unit/:time_unit_id/progress/:module
  def module_progress
    userId = params[:user_id]
    time_unit_id = params[:time_unit_id]
    mod = params[:module]


  end

  # GET /user/:id/data/academics/:time_unit_id
  def user_classes
    userId = params[:id]
    time_unit_id = params[:time_unit_id]

    classes = ProgressService.new.get_user_classes(userId, time_unit_id)

    render status: :ok,
      json: {
        info: "User's academics data",
        user_classes: classes
      }
  end

  # POST /user/:id/classes
  def add_user_class
    userId = params[:id]
    new_class = params[:user_class]

    user_class = ProgressService.new.save_user_class(userId, new_class)

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

    user_class = ProgressService.new.update_user_class(updated_class)

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

    if ProgressService.new.delete_user_class(classId)
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
