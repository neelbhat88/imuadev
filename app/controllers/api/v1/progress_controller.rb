class Api::V1::ProgressController < ApplicationController
  respond_to :json

  before_filter :authenticate_user!
  skip_before_filter :verify_authenticity_token
  before_filter :load_services
<<<<<<< HEAD

  def load_services( progressService=nil, milestoneService=nil, userRepo=nil )
=======
  def load_services( progressService=nil, milestoneService=nil, userClassService=nil, userRepo=nil, userServiceActivityService=nil, userExtracurricularActivityService=nil )
    @userClassService = userClassService ? userClassService : UserClassService.new
>>>>>>> master
    @progressService = progressService ? progressService : ProgressService.new
    @milestoneService = milestoneService ? milestoneService : MilestoneService.new
    @userRepository = userRepo ? userRepo : UserRepository.new
    @userServiceActivityService = userServiceActivityService ? userServiceActivityService : UserServiceActivityService.new
  end

  # GET /user/:id/time_unit/:time_unit_id/progress
  # Returns All modules for a given semester and the
  # total points avaiable in each module and the user's points earned
  def all_modules_progress
    userId = params[:id]
    time_unit_id = params[:time_unit_id]

    result = @progressService.get_all_progress(userId, time_unit_id)

    render status: result.status,
      json: {
        info: result.info,
        modules_progress: result.object
      }
  end

  # GET /user/:id/progress
  # Returns object with total user points, overall points, and percent complete
  # overall across all semesters
  def overall_progress
    userId = params[:id]

    result = @progressService.overall_progress(userId)

    render status: result.status,
      json: {
        info: result.info,
        overall_progress: result.object
      }
  end

  # get /user/:id/time_unit/:time_unit_id/progress/:module
  # Runs through milestones of a given module to see if any have been earned
  def module_progress
    userId = params[:id]
    time_unit_id = params[:time_unit_id]
    mod = params[:module]

    result = @progressService.check_progress(userId, time_unit_id, mod)

    render status: result.status,
      json: {
        info: result.info,
        module_progress: result.object
      }
  end

  # GET  /user/:id/time_unit/:time_unit_id/milestones/:module/yesno
  def yes_no_milestones
    userId = params[:id]
    time_unit_id = params[:time_unit_id]
    mod = params[:module]

    result = @milestoneService.yes_no_milestones_including_user(userId, mod, time_unit_id)

    render status: result.status,
      json: {
        info: result.info,
        yes_no_milestones: result.object
      }
  end

  # POST /user/:id/time_unit/:time_unit_id/milestones/:milestone_id
  def add_user_milestone
    userId = params[:id]
    time_unit_id = params[:time_unit_id]
    milestone_id = params[:milestone_id]

    result = @milestoneService.add_user_milestone(userId, time_unit_id, milestone_id)

    render status: result.status,
      json: {
        info: result.info,
        milestone: result.object
      }
  end

  # DELETE /user/:id/time_unit/:time_unit_id/milestones/:milestone_id
  def delete_user_milestone
    userId = params[:id]
    time_unit_id = params[:time_unit_id]
    milestone_id = params[:milestone_id]

    result = @milestoneService.delete_user_milestone(userId, time_unit_id, milestone_id)

    render status: result.status,
      json: {
        info: result.info
      }
  end

<<<<<<< HEAD
=======
  ###############################################################
  ###############  User Activities and Events ###################
  ###########  Move into separate controller soon ###############
  ###############################################################

  # GET /user/:id/time_unit/:time_unit_id/classes
  def user_classes
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

    classes = @userClassService.get_user_classes(userId, time_unit_id)

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

>>>>>>> master
end
