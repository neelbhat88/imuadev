class Api::V1::ProgressController < ApplicationController

  before_filter :authenticate_user!
  skip_before_filter  :verify_authenticity_token

  respond_to :json

  # GET /progress/modules
  # Returns All modules for a students current semester and the
  # total points avaiable in each module and the user's points earned
  def all_modules_progress
    userId = params[:user_id]
    orgId = params[:organization_id]
    time_unit_id = params[:time_unit_id]

    enabled_modules = EnabledModules.new.get_modules(orgId)

    modules_progress = []
    enabled_modules.each do | m |

      m.submodules.each do | sm |
        total_points = sm.total_milestone_points(time_unit_id)
        user_points = sm.total_user_points(userId, time_unit_id)

        modObj = {:module_title => m.title, :points=>{:total=>total_points, :user=>user_points} }
        modules_progress << modObj
      end
    end

    render status: :ok,
      json: {
        info: "Module progress points",
        modules_progress: modules_progress
      }
  end

  # GET /user/:id/data/academics/:time_unit_id
  def user_classes
    userId = params[:id]
    time_unit_id = params[:time_unit_id]

    classes = ProgressRepository.new.get_user_classes(userId, time_unit_id)

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

    user_class = ProgressRepository.new.save_user_class(userId, new_class)

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

    user_class = ProgressRepository.new.update_user_class(updated_class)

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
end