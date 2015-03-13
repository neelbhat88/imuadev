class Api::V1::MilestoneController < ApplicationController

  before_filter :authenticate_user!
  skip_before_filter :verify_authenticity_token
  respond_to :json
  before_filter :load_services

  def load_services ( assignmentService = nil, milestoneService = nil )
    @assignmentService = assignmentService ? assignmentService : AssignmentService.new(current_user)
    @milestoneService = milestoneService ? milestoneService : MilestoneService.new(current_user)
  end

  # GET /milestone/:id/status
  def get_milestone_status
    url_params = params.except(*[:id, :controller, :action]).symbolize_keys
    url_params[:milestone_id] = params[:id]

    if !can?(current_user, :get_milestone_status, Milestone.where(id: params[:id]).first)
      render status: :forbidden, json: {}
      return
    end

    result = @milestoneService.get_milestone_status(url_params)

    render status: result.status,
      json: Oj.dump({ info: result.info, organization: result.object }, mode: :compat)
  end

  # POST /milestone
  def create_milestone
    tuId = params[:milestone][:time_unit_id]
    mod = params[:milestone][:module]
    submod = params[:milestone][:submodule]
    importance = params[:milestone][:importance]
    points = params[:milestone][:points]
    title = params[:milestone][:title]
    desc = params[:milestone][:description]
    is_default = params[:milestone][:is_default]
    value = params[:milestone][:value]
    icon = params[:milestone][:icon]
    organizationId = TimeUnit.where(id: tuId).first.organization_id

    milestone = { :module => mod, :submodule=> submod, :importance => importance, :points => points,
                  :title => title, :description => desc, :value => value, :time_unit_id => tuId,
                  :is_default => is_default, :icon => icon, :organization_id => organizationId }

    result = @milestoneService.create_milestone(milestone)

    viewMilestone = ViewMilestone.new(result.object) unless result.object.nil?
    render status: result.status,
      json: {
        info: result.info,
        milestone: viewMilestone
      }
  end

  # PUT /milestone/:id
  def update_milestone
    milestoneId = params[:id]
    milestone = params[:milestone]

    if milestone[:id].nil?
      milestone[:id] = milestoneId
    end

    result = @milestoneService.update_milestone(milestone)

    viewMilestone = ViewMilestone.new(result.object) unless result.object.nil?
    render status: result.status,
      json: {
        info: result.info,
        milestone: viewMilestone
      }
  end

  # DELETE /milestone/:id
  def delete_milestone
    milestoneId = params[:id]

    result = @milestoneService.delete_milestone(milestoneId)

    render status: result.status,
      json: {
        info: result.info
      }
  end

  # Temporary method to update all milestone org_ids
  # GET /milestone/update_org_id
  def update_org_id
    Milestone.all.each do | m |
      m.update_attributes(:organization_id => m.time_unit.organization_id)
    end

    render status: :ok,
      json: {
        info: "Updated all milestones"
      }
  end

##############
# Assignment #
##############

  # POST /milestone/:id/assignment
  def assignment
    service_params = params.except(*[:id, :controller, :action]).symbolize_keys
    service_params[:assignment_owner_id] = params[:id].to_i
    service_params[:assignment_owner_type] = "Milestone"

    owner_object = service_params[:assignment_owner_type].classify.constantize.where(id: service_params[:assignment_owner_id]).first
    if !can?(@current_user, :create_assignment, owner_object)
      render status: :forbidden, json: {}
      return
    end

    result = @assignmentService.create(service_params)

    render status: result.status,
      json: Oj.dump( { info: result.info, organization: result.object }, mode: :compat)
  end

  # POST /milestone/:id/create_assignment_broadcast
  def create_assignment_broadcast
    service_params = params.except(*[:id, :controller, :action]).symbolize_keys
    service_params[:assignment_owner_id] = params[:id].to_i
    service_params[:assignment_owner_type] = "Milestone"

    owner_object = service_params[:assignment_owner_type].classify.constantize.where(id: service_params[:assignment_owner_id]).first
    if !can?(@current_user, :create_assignment_broadcast, owner_object)
      render status: :forbidden, json: {}
      return
    end

    result = @assignmentService.create_broadcast(service_params)

    render status: result.status,
      json: Oj.dump( { info: result.info, organization: result.object }, mode: :compat)
  end

  # GET /milestone/:id/assignments
  def assignments
    service_params = params.except(*[:id, :controller, :action]).symbolize_keys
    service_params[:assignment_owner_id] = params[:id].to_i
    service_params[:assignment_owner_type] = "Milestone"

    owner_object = service_params[:assignment_owner_type].classify.constantize.where(id: service_params[:assignment_owner_id]).first
    if !can?(@current_user, :index_assignments, owner_object)
      render status: :forbidden, json: {}
      return
    end

    result = @assignmentService.index(service_params)

    render status: result.status,
      json: Oj.dump( { info: result.info, organization: result.object }, mode: :compat)
  end

  # GET /milestone/:id/get_task_assignable_users
  def get_task_assignable_users
    service_params = params.except(*[:id, :controller, :action]).symbolize_keys
    service_params[:milestone_id] = params[:id]
    service_params[:assignment_owner_id] = params[:id].to_i
    service_params[:assignment_owner_type] = "Milestone"

    owner_object = service_params[:assignment_owner_type].classify.constantize.where(id: service_params[:assignment_owner_id]).first
    if !can?(current_user, :get_task_assignable_users, owner_object)
      render status: :forbidden, json: {}
      return
    end

    result = @milestoneService.get_task_assignable_users(service_params)

    render status: result.status,
      json: Oj.dump( { info: result.info, organization: result.object }, mode: :compat)
  end

  # GET /milestone/:id/get_task_assignable_users_tasks
  def get_task_assignable_users_tasks
    service_params = params.except(*[:id, :controller, :action]).symbolize_keys
    service_params[:milestone_id] = params[:id]
    service_params[:assignment_owner_id] = params[:id].to_i
    service_params[:assignment_owner_type] = "Milestone"

    owner_object = service_params[:assignment_owner_type].classify.constantize.where(id: service_params[:assignment_owner_id]).first
    if !can?(current_user, :get_task_assignable_users_tasks, owner_object)
      render status: :forbidden, json: {}
      return
    end

    result = @milestoneService.get_task_assignable_users_tasks(service_params)

    render status: result.status,
      json: Oj.dump( { info: result.info, organization: result.object }, mode: :compat)
  end
end
