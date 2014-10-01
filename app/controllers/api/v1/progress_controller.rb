class Api::V1::ProgressController < ApplicationController
  respond_to :json

  before_filter :authenticate_user!
  skip_before_filter :verify_authenticity_token
  before_filter :load_services
  def load_services( progressService=nil, milestoneService=nil, userRepo=nil, orgRepo=nil, userService=nil)
    @progressService = progressService ? progressService : ProgressService.new
    @milestoneService = milestoneService ? milestoneService : MilestoneService.new
    @userRepository = userRepo ? userRepo : UserRepository.new
    @organizationRepository = orgRepo ? orgRepo : OrganizationRepository.new
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

  # GET /users/:id/student_dashboard
  def student_expectations
    url_params = params.except(*[:id, :controller, :action]).symbolize_keys
    url_params[:user_id] = params[:id]

    if !can?(current_user, :get_student_expectations, User.where(id: params[:id]).first)
      render status: :forbidden, json: {}
      return
    end

    result = @progressService.get_student_expectations(url_params)

    render status: result.status,
      json: Oj.dump({
        info: result.info,
        organization: result.object
      }, mode: :compat)
  end

  # GET /users/:id/student_dashboard
  def student_dashboard
    url_params = params.except(*[:id, :controller, :action]).symbolize_keys
    url_params[:user_id] = params[:id]

    if !can?(current_user, :get_student_dashboard, User.where(id: params[:id]).first)
      render status: :forbidden, json: {}
      return
    end

    result = @progressService.get_student_dashboard(url_params)

    render status: result.status,
      json: Oj.dump({
        info: result.info,
        organization: result.object
      }, mode: :compat)
  end

  # GET /users/:id/progress_2?time_unit_id=XX&module=XX&recalculate=XX
  # Returns User's info and progress, filterable by time_unit and module.
  # Optional "recalculate" parameter to perform milestone recalculation.
  def user_progress
    url_params = params.except(*[:id, :controller, :action]).symbolize_keys
    url_params[:user_id] = params[:id]

    if !can?(current_user, :get_user_progress, User.where(id: params[:id]).first)
      render status: :forbidden, json: {}
      return
    end

    result = @progressService.get_user_progress(url_params)

    render status: result.status,
      json: Oj.dump({
        info: result.info,
        organization: result.object
      }, mode: :compat)
  end

  # get /user/:id/time_unit/:time_unit_id/progress/:module
  # Runs through milestones of a given module to see if any have been earned
  def module_progress
    userId = params[:id]
    time_unit_id = params[:time_unit_id]
    mod = params[:module]

    result = @progressService.get_recalculated_module_progress(userId, time_unit_id, mod)

    render status: result.status,
      json: {
        info: result.info,
        module_progress: result.object
      }
  end

  # get /progress/recalculated_milestones?user_id=#&time_unit_id=#module_title=#
  # Runs through milestones of a given module to see if any have been earned
  def get_recalculated_milestones
    userId = params[:user_id]
    timeUnitId = params[:time_unit_id]
    moduleTitle = params[:module_title]

    # TODO
    # user = @userRepository.get_user(userId)
    # if !can?(current_user, :read_milestones, user)
    #   render status: :forbidden,
    #     json: {}
    #   return
    # end

    # TODO
    # org = @organizationRespository.get_organization(user.organization_id)
    # if !can?(current_user, :read_milestones, org)
    #   render status: :forbidden,
    #     json: {}
    #   return
    # end

    result = @progressService.get_recalculated_milestones(userId, timeUnitId, moduleTitle)

    render status: result.status,
      json: {
        info: result.info,
        recalculated_milestones: result.object
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

end
